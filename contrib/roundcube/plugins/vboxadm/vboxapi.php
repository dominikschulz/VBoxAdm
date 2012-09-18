<?php
class VBoxAPI {
    // see http://www.perturb.org/display/PHP_to_Perl_encryption.html
    
    private $config;
    private $debug;
    
    public function setConfig($config) {
            $this->config = $config;
    }
    
    public function setDebug($debug = 0) {
        $this->debug = $debug;
    }
    
    public function get_domain_config($domain_id) {
        $req = array();
        $req['auth']['ro'] = 1; // request read-only mode
        $req['domain']['read'][$domain_id] = 1;
        
        $arr = $this->get_url($this->build_url($req));
        $res = $this->decrypt($arr[0]);
        
        if($this->debug) {
                $debug_str = '';
                $debug_str .= print_r($req,TRUE);
                $debug_str .= print_r($arr,TRUE);
                $debug_str .= print_r($res,TRUE);
                write_log('vboxadm',$debug_str);
        }
        
        return $res['domain']['read'][$domain_id]['rv'];
    }
    
    public function get_user_config($username) {
        $req = array();
        $req['auth']['ro'] = 1; // request read-only mode
        $req['mailbox']['read'][$username] = 1;
        
        $arr = $this->get_url($this->build_url($req));
        $res = $this->decrypt($arr[0]);
        
        if($this->debug) {
                $debug_str = '';
                $debug_str .= print_r($req,TRUE);
                $debug_str .= print_r($arr,TRUE);
                $debug_str .= print_r($res,TRUE);
                write_log('vboxadm',$debug_str);
        }
        
        return $res['mailbox']['read'][$username]['rv'];
    }
    
    public function set_user_config($username,$password,$fields) {
        $req = array();
        $req['auth']['rw'] = 1; // request read-write mode
        $req['user']['username'] = utf8_encode($username);
        $req['user']['password'] = utf8_encode($password);
        // modify values in place
        foreach ($fields as &$value) {
                $value = utf8_encode($value);
        }
        $req['mailbox']['update'][$username] = $fields;
        
        $arr = $this->get_url($this->build_url($req));
        $res = $this->decrypt($arr[0]);
        
        if(empty($res)) {
                return array(FALSE, 'Decode error');
        }
        
        if($this->debug) {
                $debug_str = '';
                $debug_str .= print_r($req,TRUE);
                $debug_str .= print_r($arr,TRUE);
                $debug_str .= print_r($res,TRUE);
                write_log('vboxadm',$debug_str);
        }
        
        if($res['action'] == 'ok') {
            return array(TRUE, $res['mailbox']['update'][$username]['msgs']);
        } else {
            return array(FALSE, $res['error']['str']);
        }
    }
    
    private function build_url($request) {
        return $this->config['api_url'].'?rm=api&v=1&p='.$this->encrypt($request);
    }
    
    private function encrypt($request) {
        $raw_key = $this->config['api_key'];
        $json_string = json_encode($request);
        $key = $this->gen_key($raw_key);
        $iv = $this->gen_iv($raw_key);
        $ciphertext = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$json_string,MCRYPT_ENCRYPT,$iv);
        $b64 = base64_encode($ciphertext);
        $urlenc = urlencode($b64);
        if($this->debug) {
            $debug_str = "encrypt - ";
            $debug_str .= "Raw-Key: $raw_key - ";
            $debug_str .= "JSON: $json_string - ";
            $debug_str .= "Key: $key - ";
            $debug_str .= "IV: $iv - ";
            //$debug_str .= "Ciphertext: $ciphertext - ";
            $debug_str .= "Base64: $b64 - ";
            $debug_str .= "Urlenc: $urlenc - ";
            $debug_str .= "JSON-Error: ".json_last_error();
            write_log('vboxadm',$debug_str);
        }
        return $urlenc;
    }
    
    private function prepare_json($input) {
   
        //This will convert ASCII/ISO-8859-1 to UTF-8.
        //Be careful with the third parameter (encoding detect list), because
        //if set wrong, some input encodings will get garbled (including UTF-8!)
        $imput = mb_convert_encoding($input, 'UTF-8', 'ASCII,UTF-8,ISO-8859-1');
       
        //Remove UTF-8 BOM if present, json_decode() does not like it.
        if(substr($input, 0, 3) == pack("CCC", 0xEF, 0xBB, 0xBF)) $input = substr($input, 3);
       
        return $input;
    }
    
    private function decrypt($ciphertext) {
        $raw_key = $this->config['api_key'];
        $key = $this->gen_key($raw_key);
        $iv = $this->gen_iv($raw_key);
        $urldec = urldecode($ciphertext);
        $b64dec = base64_decode($urldec);
        $json_string = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$b64dec,MCRYPT_DECRYPT,$iv);
        $json_string_trimmed = rtrim($json_string,chr(0));
        $json_string_preped = $this->prepare_json($json_string_trimmed);
        $array = json_decode($json_string_preped,1);
        if($this->debug) {
            $debug_str = "decrypt - ";
            $debug_str .= "Raw-Key: $raw_key - ";
            $debug_str .= "Key: $key - ";
            $debug_str .= "IV: $iv - ";;
            $debug_str .= "Ciphertext: $ciphertext - ";
            $debug_str .= "Urldec: $urldec - ";
            //$debug_str .= "Base64: $b64dec - ";
            $debug_str .= "JSON: $json_string - ";
            $debug_str .= "JSON-rtrim: $json_string_trimmed - ";
            $debug_str .= "JSON-prep: $json_string_preped - ";
            $debug_str .= "Array: - ";
            $debug_str .= print_r($array,TRUE);
            $debug_str .= " - JSON-Error: ".json_last_error();
            write_log('vboxadm',$debug_str);
        }
        return $array;
    }
    
    private function gen_key($raw_key) {
            return substr(mhash(MHASH_SHA512,$raw_key),0,56);
    }
    
    private function gen_iv($raw_key) {
            return substr(mhash(MHASH_SHA512,$raw_key),56);
    }
    
    /* http://de.php.net/manual/en/ref.curl.php */
    private function get_url($url, $redirect_loop = 0, $timeout = 30) {
        if($this->debug) {
                write_log('vboxadm','get_url - '.$url);
        }
        $ch = curl_init();
        curl_setopt( $ch, CURLOPT_USERAGENT, "VBoxAdm/Curl-PHP" );
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
        curl_setopt( $ch, CURLOPT_URL, $url );
        curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, $timeout );
        curl_setopt( $ch, CURLOPT_TIMEOUT, $timeout );
        curl_setopt( $ch, CURLOPT_MAXREDIRS, 10 );
        $content = curl_exec( $ch );
        $response = curl_getinfo( $ch );
        curl_close ( $ch );
        return array( $content, $response );
    }
}
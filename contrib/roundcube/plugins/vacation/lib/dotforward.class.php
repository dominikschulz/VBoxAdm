<?php

/*
 * DotForward helper class
 *
 * @package	plugin
 * @uses	rcube_plugin
 * @author	Jasper Slits <jaspersl at gmail dot com>
 * @version	1.9
 * @license     GPL
 * @link	https://sourceforge.net/projects/rcubevacation/
 * @todo	See README.TXT
*/
class DotForward {

    private $options = array("binary"=>"",
        "username"=>"",
        "flags"=>"",
        "aliases"=>"",
        "enabled"=>false,
        "forward"=>null,
        "envelop_sender"=>null,
        "keepcopy"=>false);

// set options to be used with create()
    public function setOption($key, $value) {
        $this->options[$key] = $value;
    }
    
    public function mergeOptions(array $cfgArr) {
        $this->options = array_merge($this->options, $cfgArr);
    }

// Creates the content for the .forward file
    public function create() {
	$arrDotForward = array();


        // If keep copy is not enabled, do not use \username. 
        if ($this->options['keepcopy'])
        {
            $arrDotForward[] = $this->options['keepcopy'] = "\\".$this->options['username'];
        }

        if ($this->options['forward'] != null && $this->options['forward'] != "") {
            // Only when keepcopy is enabled, use a comma
            $arrDotForward[] = $this->options['forward'];
        }

        // Create aliases
        if ($this->options['aliases'] != null) {
            // Strip leading and trailing slashes. Convert colons to spaces
            $this->options['aliases'] = str_replace(",", " ", $this->options['aliases']);
            $aliases = explode(" ", trim($this->options['aliases']));

            // Creates -a alias1 -a alias2
            foreach ($aliases as $alias) {
                $this->options['flags'] .= " -a " . $alias;
            }
        }

        // If the vacation binary supports -R for envelop sender, use this.
        // TODO: support for Debian (-z)
        if ($this->options['envelop_sender'] != null) {
            $this->options['flags'] .= " -R " . $this->options['envelop_sender'];
        }
		



        // If there is no binary set, we do not send an out office reply.
        if ($this->options['binary'] != "") {
            $arrDotForward[] = sprintf('"|%s %s %s"',$this->options['binary'], $this->options['flags'], $this->options['username']);

        } 

	return join(",",$arrDotForward);
        
    }
    
    public function parse($dotForward) {

        // Clean up the .forward file for easier parsing
        $dotForward = str_replace(array("|", "\"", "\\"), "", $dotForward);

		

        $arr = explode(",", trim($dotForward));

        $first_element = array_shift($arr);

		// @TODO: test to see if $first_element equals vacation binary

        $this->options['keepcopy'] = ($first_element == $this->options['username']);
        if (!$this->options['keepcopy']) { $this->options['forward'] = $first_element; }

        // Check for aliases
        $aliasArr = array();
        while ($tmp = strstr($dotForward, "-a")) {
            $tmpArr = explode(" ", $tmp);
            array_shift($tmpArr);
            $aliasArr[] = array_shift($tmpArr);
            $dotForward = join(" ", $tmpArr);
        }
        // Join the elements
        $this->options["aliases"] = trim(join(",", $aliasArr));

        // Location of the vacation binary may very, so we only look for the slash
        while ($next = array_shift($arr)) {
            if (substr($next, 0, 1) == '/') {
                // For future use like parsing the flags?
                list($this->options['binary']) = explode(" ", $next);

                // Checkbox will be checked
                $this->options['enabled'] = !empty($this->options['binary']);
            } else {

                $this->options['forward'] = $next;
            }
        }

        return $this->options;
    }
}

?>
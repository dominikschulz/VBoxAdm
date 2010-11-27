<?php
/*
 * Virtual/SQL driver
 *
 * @package	plugins
 * @uses	rcube_plugin
 * @author	Dominik Schulz
 * @version	1.9
 * @license GPL
 * @link	https://vboxadm.gauner.org/
 * @todo	See README.TXT
 */

class Vboxadm extends VacationDriver {

	private $db, $domain, $domain_id, $local_part, $goto = "";
	private $db_user;

	public function init() {
		// Use the DSN from db.inc.php or a dedicated DSN defined in config.ini

		if (empty($this->cfg['dsn'])) {
			$this->db = $this->rcmail->db;
			$dsn = MDB2::parseDSN($this->rcmail->config->get('db_dsnw'));
		} else {
			$this->db = new rcube_mdb2($this->cfg['dsn'], '', FALSE);
			$this->db->db_connect('w');

			$this->db->set_debug((bool) $this->rcmail->config->get('sql_debug'));
			$dsn = MDB2::parseDSN($this->cfg['dsn']);
			$this->db->set_debug(true);

		}
		// Save username for error handling
		$this->db_user = $dsn['username'];

		list($this->local_part, $this->domain) = explode("@", $this->user->get_username());
		$this->domainLookup();
	}

	/*
	 * @return Array Values for the form
	 */
	public function _get() {
		$vacArr = array(
			"subject"	=>	"",
			"body"		=>	"",
		);

		$sql = "SELECT vacation_subj AS subject,vacation_msg AS body,is_on_vacation AS active FROM ".$this->cfg['dbase'].".mailboxes WHERE local_part = ? AND domain_id = ?";

		$res = $this->db->query($sql, $this->local_part, $this->domain_id);
		if ($error = $this->db->is_error()) {
			raise_error(array(
				'code' => 601,
				'type' => 'db',
				'file' => __FILE__,
            			'message' => "Vacation plugin: query on {$this->cfg['dbase']}.vacation failed. ".
            				 "Check DSN and verify that SELECT privileges on {$this->cfg['dbase']}.vacation are granted to user '{$this->db_user}'. <br/><br/>Error message:  " . $error,
			), true, true);
		}

		if ($row = $this->db->fetch_assoc($res)) {
			$vacArr['body'] = $row['body'];
			$vacArr['subject'] = $row['subject'];
			$vacArr['enabled'] = ($row['active'] == 1);
		}

		return $vacArr;
	}

	/*
	 * @return boolean True on succes, false on failure
	 */
	public function setVacation() {
		// If there is an existing entry in the vacation table, delete it.
		// This also triggers the cascading delete on the vacation_notification, but's ok for now.

		// We store since version 1.6 all data into one row.
		$aliasArr = array();

		// Sets class property
		$this->domain_id = $this->domainLookup();

		$sql = "UPDATE ".$this->cfg['dbase'].".mailboxes SET is_on_vacation = 0 WHERE local_part = ?";

		$this->db->query($sql, $this->local_part);

		$update = ($this->db->affected_rows() == 1);

		// (Re)enable the vacation message
		if ($this->enable && $this->body != "" && $this->subject != "") {

			$sql = "UPDATE ".$this->cfg['dbase'].".mailboxes SET vacation_subj = ?, vacation_msg = ?, is_on_vacation = 1 WHERE local_part = ? AND domain_id = ?";
			$this->db->query($sql, $this->subject, $this->body, $this->local_part, $this->domain_id);
			if ($error = $this->db->is_error()) {
				if (strpos($error, "no such field")) {
					$error = " Configure either domain_lookup_query or use \%d in config.ini's insert_query rather than \%i<br/><br/>";
				}

				raise_error(array(
					'code' => 601,
					'type' => 'db',
					'file' => __FILE__,
                    'message' => "Vacation plugin: Error while saving records to {$this->cfg['dbase']}.vacation table.".
                    			 "<br/><br/>" . $error,
				), true, true);
			}
			$aliasArr[] = '%g';
		}
		return true;
	}

	// Lookup the domain_id based on the domainname. Returns the domainname if the query is empty
	private function domainLookup() {
		if(empty($this->domain_id)) {
			$sql = "SELECT id FROM ".$this->cfg['dbase'].".domains WHERE name = ?";
			$res = $this->db->query($sql, $this->domain);

			if (!$row= $this->db->fetch_array($res)) {
				raise_error(array(
					'code' => 601,
					'type' => 'db',
					'file' => __FILE__,
                    'message' => "Vacation plugin: domain_lookup_query did not return any row. ".
                            	 "Check config.ini <br/><br/>" . $this->db->is_error()
				), true, true);

			}
			$this->domain_id = $row[0];
		}
		return $this->domain_id;
	}

	// Destroy the database connection of our temporary database connection
	public function __destruct() {
		if (!empty($this->cfg['dsn']) && is_resource($this->db)) {
			$this->db = null;
		}
	}
}

?>

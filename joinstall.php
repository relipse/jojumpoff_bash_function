<?php
$INSTALL['basename'] = 'jo.bashrc';
$INSTALL['fullpath'] = dirname(__FILE__).'/'.$INSTALL['basename'];

$options = array('make_backup'=>true);

if (!file_exists($INSTALL['fullpath'])){
	die($INSTALL['basename'].' does not exist, cannot install nothing.'."\n");
}
$install_autocompletion = false;

$homepath = getenv('home');
if (empty($homepath)){
	//echo "Warning: getenv('home') is not working properly. Using another method...\n";
	$cdpwd_homepath = trim(shell_exec('cd ~/ && pwd'));
	//echo 'Guessing homepath as '.$home."\n";
	$whoami = trim(shell_exec('whoami'));
	//echo 'whoami: '.$whoami."\n";
	if ($whoami == 'root'){
		$homepath = '/root';
		if ($cdpwd_homepath !== $homepath){
			die($cdpwd_homepath.' differs from '.$homepath);
		}
		echo "homepath set as $homepath\n";
	}else{
		$homepath = '/home/'.$whoami;
		if ($cdpwd_homepath !== $homepath){
            $homepath = "/Users/$whoami";
            if ($cdpwd_homepath !== $homepath) {
                die($cdpwd_homepath . ' differs from ' . $homepath);
            }
		}
       		//echo ('You do not have a $HOME path or getenv("home") is incorrect'."\n");
       		echo "homepath set as $homepath\n";
         }
}

$INSTALL['mkdir'] = $homepath.'/jo/';


@mkdir($INSTALL['mkdir']);

if (! file_exists($INSTALL['mkdir']) ){
	die($INSTALL['mkdir'].' does not exist and cannot be created. Install Aborted.'."\n");
}

$bashrc = '.bashrc';
$bashrc_fullpath = $homepath.'/'.$bashrc;

if (!file_exists($bashrc_fullpath)){
	die($bashrc_fullpath.' does not exist. Aborting install.'."\n");
}

$bashrc_contents = file_get_contents($bashrc_fullpath);

//---------------UPGRADE IF JO FUNCTION ALREADY EXISTS in .bashrc ----------------------------
$BEGINMARK = 'function jo';
$ENDMARK = '###endjo';

$begpos = strpos($bashrc_contents, $BEGINMARK);
$endpos = strpos($bashrc_contents, $ENDMARK);


if ($begpos === false || $endpos === false){
     $upgrade = false;
}
else if ($begpos > $endpos){
	$upgrade = false;
	die('Error clean existing .bashrc file of jo script');
}else{
	$upgrade = true;
}

if ($upgrade){
	echo 'Found existing jo in .bashrc file, doing upgrade.'."\n";
	$length = $endpos - $begpos;
	$remove_this = substr($bashrc_contents, $begpos, $length+strlen($ENDMARK));
    
	echo 'Removing '.count(explode("\n", $remove_this)).' lines from existing .bashrc file.'."\n";

	$newbashrc_contents = str_replace($remove_this, '', $bashrc_contents);
	
}else{
	$newbashrc_contents = $bashrc_contents;
}

$uninstall = false;
if (!empty($argv[1])){
	foreach($argv as $i => $arg){
		switch(strtolower($arg)){
			case '--remove':
		        case '--uninstall':
		        
		        	$uninstall = true;
		        break;
		        case '--autocompletion':
		        case '--completion':
		        	$install_autocompletion = true;
		        break;
		}
	}
}


if ($install_autocompletion){
	 $ac_file = '/etc/bash_completion.d/jojumpoff';
	 if (file_exists($ac_file)){
	 	if ($uninstall){
	 		unlink($ac_file);
	 	}else{
	 	   echo 'Error: First remove '.$ac_file.' either by php joinstall.php --uninstall --completion or using rm manually'."\n";
	 	}
	 }else{
	 	//good file doesnt exist, first install
	 	$accontents = file_get_contents(dirname(__FILE__).'/jojumpoff.autocompletion');
	 	file_put_contents($ac_file, $accontents);
	 	echo "Reload autocompletion by doing: . $ac_file\n";
	 	exit(0);
	 }
}

if (!$uninstall){
  //append jo to end of .bashrc
  $newbashrc_contents .= "\n";
  $newbashrc_contents .= file_get_contents($INSTALL['fullpath']);
  echo "New jo source appended to end of .bashrc\n";
}

if ($options['make_backup']){
	copy($bashrc_fullpath, $bashrc_fullpath.'.backup-'.date('Y-m-d_His'));
}


if (file_put_contents($bashrc_fullpath, $newbashrc_contents)){
	if ($uninstall){
		echo 'Uninstall complete. Check ~/.bashrc for proof!'."\n";
		exit(0);
	}
	$cmd = "source ".escapeshellarg($bashrc_fullpath);
	echo "New .bashrc file, install almost complete.\nRemember to do one of these: \n";
	echo $cmd."\n";
    echo "source ~/.bashrc\n";
	exit(0);
}else{
	echo "Error writing to .bashrc file";
	exit(1);
}

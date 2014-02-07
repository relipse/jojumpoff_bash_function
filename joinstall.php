<?php
$INSTALL['basename'] = 'jo.bashrc';
$INSTALL['fullpath'] = dirname(__FILE__).'/'.$INSTALL['basename'];

$options = array('make_backup'=>true);

if (!file_exists($INSTALL['fullpath'])){
	die($INSTALL['basename'].' does not exist, cannot install nothing.'."\n");
}

$homepath = getenv('home');
if (empty($homepath)){
	echo "Warning: getenv('home') is not working properly. Using another method...\n";
	$home = shell_exec('cd ~/ && pwd');
	echo 'Guessing homepath as '.$home."\n";
	$whoami = trim(shell_exec('whoami'));
	echo 'whoami: '.$whoami."\n";
	if ($whoami == 'root'){
		$homepath = '/root';
		echo 'Warning: homepath is /root';
	}else{
		$homepath = '/home/'.$whoami;
		
       		echo ('You do not have a $HOME path or getenv("home") is incorrect'."\n");
       		echo "Warning: homepath set as $homepath\n";
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
	switch(strtolower($argv[1])){
		case '--remove':
	        case '--uninstall':
	        	$uninstall = true;
	}
}

if (!$uninstall){
  //append jo to end of .bashrc
  $newbashrc_contents .= "\n";
  $newbashrc_contents .= file_get_contents($INSTALL['fullpath']);
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
	echo "New .bashrc file, install almost complete. Remember to do: \n";
	echo $cmd."\n";
	exit(0);
}else{
	echo "Error writing to .bashrc file";
	exit(1);
}

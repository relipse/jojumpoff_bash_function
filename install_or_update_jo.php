<?php
/**
 * New install/upgrade php script.
 * 1. Install php 7 or php 8
 * 2. Run this script in the repo folder.
 * Usage: Most scenarios, just jon: php install-or-upgrade-jo.php
 * @author relipse
 */
const START_JO_FUNCTION = '#############################################################startjo';
const START_JO_FUNCTION_ALT = 'myjocompletion () {';
const END_JO_FUNCTION = '###############################################################endjo';
$opts = getopt('j:b:o:h', ['new-jo:', 'jo:', 'bashrc:', 'dest:', 'out:', 'help']);
$help = isset($opts['help']) || isset($opts['h']);
if ($help){
    die("install-or-upgrade-jo.php - Install jo bash function for easy executing/saving commands.\n".
        "Usage: php install-or-upgrade-jo.php [OPTIONS]\n".
        "Typically you don't need any options, just run (will modify \$HOME/.bashrc):\n".
        "php install-or-upgrade-jo.php\n\n".
        "OPTIONS\n".
        "-j,--new-jo             jo.bash file\n".
        "-b,--bashrc,--dest      Where to install to (~/.bashrc typically)\n".
        "-o,--out                if specified, will send here instead and leave .bashrc alone\n".
        "-h,--help               Show this help\n"
        );
}
$newJoSourceFile = $opts['r'] ?? $opts['jo'] ?? $opts['new-jo'] ?? 'jo.bash';
if (!file_exists($newJoSourceFile)) {
    echo $newJoSourceFile . ' does not exist.' . "\n";
    die('Use --new-jo="jo.bash" to specify new jo source.' . "\n");
}
$newJoSource = file_get_contents($newJoSourceFile);

$posStartJo = strpos($newJoSource, START_JO_FUNCTION);
$posEndJo = strpos($newJoSource, END_JO_FUNCTION);
if ($posStartJo === false) {
    die(START_JO_FUNCTION .' not found in: ' . $newJoSourceFile . "\n");
}
if ($posEndJo === false) {
    die(END_JO_FUNCTION . ' not found in: ' . $newJoSourceFile . "\n");
}

$chunk = substr($newJoSource, $posStartJo, $posEndJo-$posStartJo);
$version = null;
if (preg_match('/@version (\d+\.\d+)/', $chunk, $matches)) {
    $version = $matches[1] ?? null;
}
$upgradeToVersion = $version;
$home = getenv("HOME");
echo "Home Dir: $home\n";
$bashRcDestFile = $opts['b'] ?? $opts['bashrc'] ?? $opts['dest'] ??  $home.'/.bashrc';
if (!file_exists($bashRcDestFile)) {
    die($bashRcDestFile . ' does not exist.' . "\n");
}
echo 'Source: ' . $newJoSourceFile . "\n";
echo 'Dest: ' . $bashRcDestFile . "\n";
$outFile = $opts['out'] ?? $opts['o'] ?? $bashRcDestFile;
if ($outFile !== $bashRcDestFile) {
    echo 'Out: ' . $outFile . "\n";
}
$useAlt = false;
$bashRcDest = file_get_contents($bashRcDestFile);
$posStartJoBashRc = strpos($bashRcDest, START_JO_FUNCTION);
if ($posStartJoBashRc === false) {
    $posStartJoBashRc = strpos($bashRcDest, START_JO_FUNCTION_ALT);
    $useAlt = true;
}
$posEndJoBashRc = strpos($bashRcDest, END_JO_FUNCTION);

if ($posStartJoBashRc === false) {
    if ($posEndJoBashRc !== false) {
        die(END_JO_FUNCTION . ' found in: ' . $bashRcDestFile . "\n, but not " . ($useAlt ? START_JO_FUNCTION_ALT : START_JO_FUNCTION) . "\n");
    } else {
        //nothing in bashrc destination file, just append
        echo "Jo is not currently installed\n";
        echo "Version to install: $upgradeToVersion\n";
        $bytesWritten = file_put_contents($outFile, $bashRcDest.PHP_EOL.$newJoSource);
        if ($bytesWritten === false) {
            die("File write failed, manually append to ~/.bashrc:\n\n" . $newJoSource . "\n");
        } else {
            //SUCCESS!!!
            echo "SUCCESS!\n";
            echo $bytesWritten . ' bytes written.' . "\n";
        }
    }
} else if ($posEndJoBashRc === false) {
    die(START_JO_FUNCTION . ' found in: ' . $bashRcDestFile . "\n, but not " . END_JO_FUNCTION . "\n");
} else {
    $replace = substr($bashRcDest, $posStartJoBashRc, $posEndJoBashRc - $posStartJoBashRc + strlen(END_JO_FUNCTION));
    $version = null;
    if (preg_match('/@version (\d+\.\d+)/', $replace, $matches)) {
        $version = $matches[1] ?? null;
    }
    $fromVersion = $version;
    if ($fromVersion) {
        echo "Upgrading From Version: $fromVersion\n";
    }
    if ($upgradeToVersion) {
        echo "To Version: $upgradeToVersion\n";
        if ($upgradeToVersion === $fromVersion){
            die("Same Version. Doing nothing.\n");
        }
    }
    //echo "Found: ";
    //echo $replace;
    $dest = str_replace($replace, $newJoSource, $bashRcDest);
    $bytesWritten = file_put_contents($outFile, $dest);
    if ($bytesWritten === false) {
        die("File write failed, manually put in ~/.bashrc:\n\n" . $newJoSource . "\n");
    }
    //SUCCESS!!
    echo "SUCCESS!\n";
    echo $bytesWritten . ' bytes written.' . "\n";
}
if (!file_exists("$home/jo")){
    mkdir("$home/jo");
    echo "$home/jo directory created.\n";
}else{
    echo "$home/jo directory already exists.\n";
}

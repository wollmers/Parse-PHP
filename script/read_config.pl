use strict;
use warnings;

use Data::Dumper;

use File::Slurp;
use Parse::RecDescent;





my $config_text = read_file( 'LocalConfiguration.php' );

$config_text =~ s/return array/\$config = array/;

my $text = q(
<?php
$myarr = array(
		'debug' => 'FALSE',
		'd2'    => "TRUE",
);
?>
);

my $text2 = q(
<?php
$myarr = array(
		'debug' => FALSE,
		'explicitADmode' => 'explicitAllow',
		'installToolPassword' => '$P$ChEtqTE89mb9a88/54ZNVZS1UQ0ftj1',
		'loginSecurityLevel' => 'rsa',
);
?>
);

my $text3 = q(
<?php
$myarr = array(

	'SYS' => array(
		'caching' => array(
			'cacheConfigurations' => array(
				'extbase_object' => array(
					'backend' => 'TYPO3\\CMS\\Core\\Cache\\Backend\\ApcBackend',
					'frontend' => 'TYPO3\\CMS\\Core\\Cache\\Frontend\\VariableFrontend',
					'groups' => array(
						'system',
					),
					'options' => array(
						'defaultLifetime' => 0,
					),
				),
			),
		),
		'compat_version' => '6.2',
		'devIPmask' => '',
		'displayErrors' => FALSE,
		'enableDeprecationLog' => FALSE,
		'encryptionKey' => '2b6720eaaf10a776cde87a1f12e58f728d68c9152405c214a3febc170a159e5190c55c8fd45c0fdf6024a9c1b1e28794',
		'isInitialInstallationInProgress' => FALSE,
		'sitename' => 'www.example.com',
		'sqlDebug' => 0,
		'systemLogLevel' => 2,
		't3lib_cs_convMethod' => 'mbstring',
		't3lib_cs_utils' => 'mbstring',
	),
	);
?>
);

print $config_text;
#exit;

#<autoaction: { [@item] } >
#<autotree>

my $grammar = <<'GRAMMAR';

<autotree: PHP>

php_vars:	/\s*<\?php/ statement(s) /\s*\?>/

php_start:	/\s*<\?php/  

php_end:	/\s*\?>/  

statement:  comment | assignment

comment:    /\s*(\#|\/\/).*/ 

assignment:	variable '=' body ';'

body:       scalar | hash | array | constant

scalar:		double_quoted | single_quoted | number	

variable:	/\$[a-zA-Z_][0-9a-zA-Z_]*/

number:		/-?[0-9.]+/

string:		double_quoted | single_quoted

double_quoted:	/ " (?: [^\\"] | \\" )* " /x

single_quoted:	/'.*?'/

element:	array | scalar | hash | bareword 

pair:		scalar '=>' element

array:      /array\s*/i '(' element(s /,/) /\s*(,\s*)?/ ')'

hash:       /array\s*/i '(' pair(s /,/) /\s*(,\s*)?/ ')'

bareword:	/[0-9a-zA-Z_]+/
		
constant:	/define\s*\(/ string ',' scalar ')' 

whitespace:	/^\s+$/

GRAMMAR

my $parser = Parse::RecDescent->new( $grammar );

my $tree = $parser->php_vars($config_text);
#my $tree = $parser->php_vars($text3);


{
local $Data::Dumper::Indent = 1;
#print Dumper([$tree]);
print Dumper($tree->eval()), "\n" if $tree;
}

sub returning {
 	  local $^W;
	  #print +(caller(1))[3], " returning ($_[0])\n";
	  print +(caller(1))[3], " returning (@_)\n";
	return (@_);
}

sub PHP::php_vars::eval		{returning [ map {$_->eval()} @{$_[0]->{'statement(s)'}} ] }
sub PHP::php_start::eval	{returning '' }
sub PHP::php_end::eval		{returning '' }
sub PHP::statement::eval	{ my $type = $_[0]->{comment}||$_[0]->{assignment};
							  returning $type->eval() }
sub PHP::comment::eval		{returning '' }
#sub PHP::assignment::eval	{returning $_[0]->{'variable'}->eval() . ' = ' .  $_[0]->{'body'}->eval() . ';' ;}
sub PHP::assignment::eval	{returning $_[0]->{'body'}->eval() }
sub PHP::variable::eval		{returning $_[0]->{__VALUE__} }
sub PHP::body::eval		    {my $type = $_[0]->{'scalar'}||$_[0]->{hash}||$_[0]->{array}||$_[0]->{constant};
							  returning $type->eval() }
sub PHP::scalar::eval		{my $type = $_[0]->{double_quoted}||$_[0]->{single_quoted}||$_[0]->{number};
							  returning $type->eval() }
sub PHP::number::eval		{returning $_[0]->{__VALUE__} }							  
sub PHP::string::eval		{my $type = $_[0]->{double_quoted}||$_[0]->{single_quoted};
							  returning $type->eval() }
sub PHP::double_quoted::eval		{my $string = $_[0]->{__VALUE__};
                                       $string =~ s/^["]|["]$//g;
                                       returning $string; }
sub PHP::single_quoted::eval		{my $string = $_[0]->{__VALUE__};
                                       $string =~ s/^[']|[']$//g;
                                       returning $string;}	
sub PHP::element::eval		{my $type = $_[0]->{'scalar'}||$_[0]->{hash}||$_[0]->{array}||$_[0]->{bareword};
							  returning $type->eval() }							  
sub PHP::pair::eval		    {returning  ($_[0]->{'scalar'}->eval() , $_[0]->{'element'}->eval() ); }
#sub PHP::pair::eval         {returning 'PAIR' }
sub PHP::array::eval		{returning [ map {$_->eval()} @{$_[0]->{'element(s)'}}  ] ; }
sub PHP::hash::eval		    {returning { map {$_->eval()} @{$_[0]->{'pair(s)'}}     } ; }	
sub PHP::bareword::eval		{returning $_[0]->{__VALUE__} }	
sub PHP::constant::eval		{returning 'CONSTANT' }

=for comment

# format of PHP serialize()
# PHP::Serialization

			'pagebrowse' => 'a:0:{}',
			'realty' => 'a:15:{s:17:"enableConfigCheck";s:1:"1";s:12:"importFolder";s:0:"";s:21:"deleteZipsAfterImport";s:1:"1";s:36:"onlyImportForRegisteredFrontEndUsers";s:1:"0";s:25:"allowedFrontEndUserGroups";s:0:"";s:28:"pidForRealtyObjectsAndImages";s:0:"";s:22:"pidForAuxiliaryRecords";s:0:"";s:39:"pidsForRealtyObjectsAndImagesByFileName";s:0:"";s:50:"useFrontEndUserDataAsContactDataForImportedRecords";s:1:"0";s:12:"emailAddress";s:0:"";s:10:"onlyErrors";s:1:"0";s:20:"notifyContactPersons";s:1:"0";s:14:"openImmoSchema";s:0:"";s:11:"cliLanguage";s:2:"en";s:13:"emailTemplate";s:47:"EXT:realty/lib/tx_realty_emailNotification.tmpl";}',
'a:15:{
  s:17:"enableConfigCheck";s:1:"1";
  s:12:"importFolder";s:0:"";
  s:21:"deleteZipsAfterImport";s:1:"1";
  s:36:"onlyImportForRegisteredFrontEndUsers";s:1:"0";
  s:25:"allowedFrontEndUserGroups";s:0:"";
  s:28:"pidForRealtyObjectsAndImages";s:0:"";
  s:22:"pidForAuxiliaryRecords";s:0:"";
  s:39:"pidsForRealtyObjectsAndImagesByFileName";s:0:"";
  s:50:"useFrontEndUserDataAsContactDataForImportedRecords";s:1:"0";
  s:12:"emailAddress";s:0:"";
  s:10:"onlyErrors";s:1:"0";
  s:20:"notifyContactPersons";s:1:"0";
  s:14:"openImmoSchema";s:0:"";
  s:11:"cliLanguage";s:2:"en";
  s:13:"emailTemplate";s:47:"EXT:realty/lib/tx_realty_emailNotification.tmpl";
}',
						



'rsaauth' => 'a:1:{s:18:"temporaryDirectory";s:0:"";}',
			
			
'saltedpasswords' => 'a:2:{s:3:"BE.";a:4:{s:21:"saltedPWHashingMethod";s:41:"TYPO3\\CMS\\Saltedpasswords\\Salt\\PhpassSalt";s:11:"forceSalted";i:0;s:15:"onlyAuthService";i:0;s:12:"updatePasswd";i:1;}s:3:"FE.";a:5:{s:7:"enabled";i:1;s:21:"saltedPWHashingMethod";s:41:"TYPO3\\CMS\\Saltedpasswords\\Salt\\PhpassSalt";s:11:"forceSalted";i:0;s:15:"onlyAuthService";i:0;s:12:"updatePasswd";i:1;}}',

'a:2:{
  s:3:"BE.";a:4:{
    s:21:"saltedPWHashingMethod";s:41:"TYPO3\\CMS\\Saltedpasswords\\Salt\\PhpassSalt";
    s:11:"forceSalted";i:0;
    s:15:"onlyAuthService";i:0;
    s:12:"updatePasswd";i:1;
  }
  s:3:"FE.";a:5:{
    s:7:"enabled";i:1;
    s:21:"saltedPWHashingMethod";s:41:"TYPO3\\CMS\\Saltedpasswords\\Salt\\PhpassSalt";
    s:11:"forceSalted";i:0;
    s:15:"onlyAuthService";i:0;
    s:12:"updatePasswd";i:1;
  }
}',
			
			
'static_info_tables' => 'a:2:{s:13:"enableManager";s:1:"0";s:5:"dummy";s:1:"0";}',
			
			
't3adminer' => 'a:2:{s:8:"IPaccess";s:0:"";s:14:"applyDevIpMask";s:1:"0";}',
			
			
			
			
			
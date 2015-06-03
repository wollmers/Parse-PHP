use strict;
use warnings;

use Data::Dumper;



my $examples = [
'a:0:{}',
's:0:""',
'a:15:{s:17:"enableConfigCheck";s:1:"1";s:12:"importFolder";s:0:"";s:21:"deleteZipsAfterImport";s:1:"1";s:36:"onlyImportForRegisteredFrontEndUsers";s:1:"0";s:25:"allowedFrontEndUserGroups";s:0:"";s:28:"pidForRealtyObjectsAndImages";s:0:"";s:22:"pidForAuxiliaryRecords";s:0:"";s:39:"pidsForRealtyObjectsAndImagesByFileName";s:0:"";s:50:"useFrontEndUserDataAsContactDataForImportedRecords";s:1:"0";s:12:"emailAddress";s:0:"";s:10:"onlyErrors";s:1:"0";s:20:"notifyContactPersons";s:1:"0";s:14:"openImmoSchema";s:0:"";s:11:"cliLanguage";s:2:"en";s:13:"emailTemplate";s:47:"EXT:realty/lib/tx_realty_emailNotification.tmpl";}',
'a:1:{s:18:"temporaryDirectory";s:0:"";}',
'a:2:{s:3:"BE.";a:4:{s:21:"saltedPWHashingMethod";s:41:"TYPO3\\CMS\\Saltedpasswords\\Salt\\PhpassSalt";s:11:"forceSalted";i:0;s:15:"onlyAuthService";i:0;s:12:"updatePasswd";i:1;}s:3:"FE.";a:5:{s:7:"enabled";i:1;s:21:"saltedPWHashingMethod";s:41:"TYPO3\\CMS\\Saltedpasswords\\Salt\\PhpassSalt";s:11:"forceSalted";i:0;s:15:"onlyAuthService";i:0;s:12:"updatePasswd";i:1;}}',
'a:2:{s:13:"enableManager";s:1:"0";s:5:"dummy";s:1:"0";}',
'a:2:{s:8:"IPaccess";s:0:"";s:14:"applyDevIpMask";s:1:"0";}',
];

my $data = $examples->[2];
my $ast = Parser->parse(\$data);
 
$Data::Dumper::Deepcopy = 1;
$Data::Dumper::Indent = 1;
print Dumper $ast;

package Parser;

use Marpa::R2;

my ($grammar);
 
sub parse {
    my ($self, $ref) = @_;
    my $recce = Marpa::R2::Scanless::R->new({ grammar => $grammar });
    $recce->read($ref);
    my $val = $recce->value // die "No parse found";
    return $$val;
}

BEGIN {
    $grammar = Marpa::R2::Scanless::G->new({
        bless_package => 'Ast',
        source => \<<'END SOURCE',
            :default    ::= action => [name,values]
            lexeme default = latm => 1
            :start      ::= Serialized
            :discard    ~   ws
            
            Serialized ::= <Item>+ separator => <op semicolon> 
            #Serialized ::= <Item>+
            
            Item       ::= 
                Array
              | String
              | Integer
              
            Array      ::= (a_id) (colon) (Count) (colon) ('{') Body ('}')
            
            Body       ::=  <Serialized>*

            String     ::= (s_id) (colon) (Count) (colon) (dquote) Chars (dquote)
            
            Chars      ::= <word>*
            
            Integer    ::= (i_id) (colon) Count 
            
            a_id       ~ 'a'
            
            s_id       ~ 's'
            
            i_id       ~ 'i'
            
            colon      ~ ':'
                
            dquote  ~ '"'

            Count   ~ <number int>
            
            word    ~ [^\x{22}]+
            #word    ~ [\w]+

            <number int> ~ [\d]+

            ws      ~ [\s]+
            <op semicolon> ~ ';'
END SOURCE
    });
}
//
//  NSString+Extend.m
//
//  Created by ajsong on 15/10/9.
//  Copyright (c) 2015 ajsong. All rights reserved.
//

#import "CommonCrypto/CommonDigest.h"
#import <CoreText/CoreText.h>

#define HANZI_START 19968
#define HANZI_COUNT 20902
static char firstLetterArray[HANZI_COUNT] =
"ydkqsxnwzssxjbymgcczqpssqbycdscdqldylybssjgyqzjjfgcclzznwdwzjljpfyynnjjtmynzwzhflzppqhgccyynmjqyxxgd"
"nnsnsjnjnsnnmlnrxyfsngnnnnqzggllyjlnyzssecykyyhqwjssggyxyqyjtwktjhychmnxjtlhjyqbyxdldwrrjnwysrldzjpc"
"bzjjbrcfslnczstzfxxchtrqggddlyccssymmrjcyqzpwwjjyfcrwfdfzqpyddwyxkyjawjffxjbcftzyhhycyswccyxsclcxxwz"
"cxnbgnnxbxlzsqsbsjpysazdhmdzbqbscwdzzyytzhbtsyyfzgntnxjywqnknphhlxgybfmjnbjhhgqtjcysxstkzglyckglysmz"
"xyalmeldccxgzyrjxjzlnjzcqkcnnjwhjczccqljststbnhbtyxceqxkkwjyflzqlyhjxspsfxlmpbysxxxytccnylllsjxfhjxp"
"jbtffyabyxbcczbzyclwlczggbtssmdtjcxpthyqtgjjxcjfzkjzjqnlzwlslhdzbwjncjzyzsqnycqynzcjjwybrtwpyftwexcs"
"kdzctbyhyzqyyjxzcfbzzmjyxxsdczottbzljwfckscsxfyrlrygmbdthjxsqjccsbxyytswfbjdztnbcnzlcyzzpsacyzzsqqcs"
"hzqydxlbpjllmqxqydzxsqjtzpxlcglqdcwzfhctdjjsfxjejjtlbgxsxjmyjjqpfzasyjnsydjxkjcdjsznbartcclnjqmwnqnc"
"lllkbdbzzsyhqcltwlccrshllzntylnewyzyxczxxgdkdmtcedejtsyyssdqdfmxdbjlkrwnqlybglxnlgtgxbqjdznyjsjyjcjm"
"rnymgrcjczgjmzmgxmmryxkjnymsgmzzymknfxmbdtgfbhcjhkylpfmdxlxjjsmsqgzsjlqdldgjycalcmzcsdjllnxdjffffjcn"
"fnnffpfkhkgdpqxktacjdhhzdddrrcfqyjkqccwjdxhwjlyllzgcfcqjsmlzpbjjblsbcjggdckkdezsqcckjgcgkdjtjllzycxk"
"lqccgjcltfpcqczgwbjdqyzjjbyjhsjddwgfsjgzkcjctllfspkjgqjhzzljplgjgjjthjjyjzccmlzlyqbgjwmljkxzdznjqsyz"
"mljlljkywxmkjlhskjhbmclyymkxjqlbmllkmdxxkwyxwslmlpsjqqjqxyqfjtjdxmxxllcrqbsyjbgwynnggbcnxpjtgpapfgdj"
"qbhbncfjyzjkjkhxqfgqckfhygkhdkllsdjqxpqyaybnqsxqnszswhbsxwhxwbzzxdmndjbsbkbbzklylxgwxjjwaqzmywsjqlsj"
"xxjqwjeqxnchetlzalyyyszzpnkyzcptlshtzcfycyxyljsdcjqagyslcllyyysslqqqnldxzsccscadycjysfsgbfrsszqsbxjp"
"sjysdrckgjlgtkzjzbdktcsyqpyhstcldjnhmymcgxyzhjdctmhltxzhylamoxyjcltyfbqqjpfbdfehthsqhzywwcncxcdwhowg"
"yjlegmdqcwgfjhcsntmydolbygnqwesqpwnmlrydzszzlyqpzgcwxhnxpyxshmdqjgztdppbfbhzhhjyfdzwkgkzbldnzsxhqeeg"
"zxylzmmzyjzgszxkhkhtxexxgylyapsthxdwhzydpxagkydxbhnhnkdnjnmyhylpmgecslnzhkxxlbzzlbmlsfbhhgsgyyggbhsc"
"yajtxglxtzmcwzydqdqmngdnllszhngjzwfyhqswscelqajynytlsxthaznkzzsdhlaxxtwwcjhqqtddwzbcchyqzflxpslzqgpz"
"sznglydqtbdlxntctajdkywnsyzljhhdzckryyzywmhychhhxhjkzwsxhdnxlyscqydpslyzwmypnkxyjlkchtyhaxqsyshxasmc"
"hkdscrsgjpwqsgzjlwwschsjhsqnhnsngndantbaalczmsstdqjcjktscjnxplggxhhgoxzcxpdmmhldgtybynjmxhmrzplxjzck"
"zxshflqxxcdhxwzpckczcdytcjyxqhlxdhypjqxnlsyydzozjnhhqezysjyayxkypdgxddnsppyzndhthrhxydpcjjhtcnnctlhb"
"ynyhmhzllnnxmylllmdcppxhmxdkycyrdltxjchhznxclcclylnzsxnjzzlnnnnwhyqsnjhxynttdkyjpychhyegkcwtwlgjrlgg"
"tgtygyhpyhylqyqgcwyqkpyyettttlhyylltyttsylnyzwgywgpydqqzzdqnnkcqnmjjzzbxtqfjkdffbtkhzkbxdjjkdjjtlbwf"
"zpptkqtztgpdwntpjyfalqmkgxbcclzfhzcllllanpnxtjklcclgyhdzfgyddgcyyfgydxkssendhykdndknnaxxhbpbyyhxccga"
"pfqyjjdmlxcsjzllpcnbsxgjyndybwjspcwjlzkzddtacsbkzdyzypjzqsjnkktknjdjgyepgtlnyqnacdntcyhblgdzhbbydmjr"
"egkzyheyybjmcdtafzjzhgcjnlghldwxjjkytcyksssmtwcttqzlpbszdtwcxgzagyktywxlnlcpbclloqmmzsslcmbjcsdzkydc"
"zjgqjdsmcytzqqlnzqzxssbpkdfqmddzzsddtdmfhtdycnaqjqkypbdjyyxtljhdrqxlmhkydhrnlklytwhllrllrcxylbnsrnzz"
"symqzzhhkyhxksmzsyzgcxfbnbsqlfzxxnnxkxwymsddyqnggqmmyhcdzttfgyyhgsbttybykjdnkyjbelhdypjqnfxfdnkzhqks"
"byjtzbxhfdsbdaswpawajldyjsfhblcnndnqjtjnchxfjsrfwhzfmdrfjyxwzpdjkzyjympcyznynxfbytfyfwygdbnzzzdnytxz"
"emmqbsqehxfznbmflzzsrsyqjgsxwzjsprytjsjgskjjgljjynzjjxhgjkymlpyyycxycgqzswhwlyrjlpxslcxmnsmwklcdnkny"
"npsjszhdzeptxmwywxyysywlxjqcqxzdclaeelmcpjpclwbxsqhfwrtfnjtnqjhjqdxhwlbyccfjlylkyynldxnhycstyywncjtx"
"ywtrmdrqnwqcmfjdxzmhmayxnwmyzqtxtlmrspwwjhanbxtgzypxyyrrclmpamgkqjszycymyjsnxtplnbappypylxmyzkynldgy"
"jzcchnlmzhhanqnbgwqtzmxxmllhgdzxnhxhrxycjmffxywcfsbssqlhnndycannmtcjcypnxnytycnnymnmsxndlylysljnlxys"
"sqmllyzlzjjjkyzzcsfbzxxmstbjgnxnchlsnmcjscyznfzlxbrnnnylmnrtgzqysatswryhyjzmgdhzgzdwybsscskxsyhytsxg"
"cqgxzzbhyxjscrhmkkbsczjyjymkqhzjfnbhmqhysnjnzybknqmcjgqhwlsnzswxkhljhyybqcbfcdsxdldspfzfskjjzwzxsddx"
"jseeegjscssygclxxnwwyllymwwwgydkzjggggggsycknjwnjpcxbjjtqtjwdsspjxcxnzxnmelptfsxtllxcljxjjljsxctnswx"
"lennlyqrwhsycsqnybyaywjejqfwqcqqcjqgxaldbzzyjgkgxbltqyfxjltpydkyqhpmatlcndnkxmtxynhklefxdllegqtymsaw"
"hzmljtkynxlyjzljeeyybqqffnlyxhdsctgjhxywlkllxqkcctnhjlqmkkzgcyygllljdcgydhzwypysjbzjdzgyzzhywyfqdtyz"
"szyezklymgjjhtsmqwyzljyywzcsrkqyqltdxwcdrjalwsqzwbdcqyncjnnszjlncdcdtlzzzacqqzzddxyblxcbqjylzllljddz"
"jgyqyjzyxnyyyexjxksdaznyrdlzyyynjlslldyxjcykywnqcclddnyyynycgczhjxcclgzqjgnwnncqqjysbzzxyjxjnxjfzbsb"
"dsfnsfpzxhdwztdmpptflzzbzdmyypqjrsdzsqzsqxbdgcpzswdwcsqzgmdhzxmwwfybpngphdmjthzsmmbgzmbzjcfzhfcbbnmq"
"dfmbcmcjxlgpnjbbxgyhyyjgptzgzmqbqdcgybjxlwnkydpdymgcftpfxyztzxdzxtgkptybbclbjaskytssqyymscxfjhhlslls"
"jpqjjqaklyldlycctsxmcwfgngbqxllllnyxtyltyxytdpjhnhgnkbyqnfjyyzbyyessessgdyhfhwtcqbsdzjtfdmxhcnjzymqw"
"srxjdzjqbdqbbsdjgnfbknbxdkqhmkwjjjgdllthzhhyyyyhhsxztyyyccbdbpypzyccztjpzywcbdlfwzcwjdxxhyhlhwczxjtc"
"nlcdpxnqczczlyxjjcjbhfxwpywxzpcdzzbdccjwjhmlxbqxxbylrddgjrrctttgqdczwmxfytmmzcwjwxyywzzkybzcccttqnhx"
"nwxxkhkfhtswoccjybcmpzzykbnnzpbthhjdlszddytyfjpxyngfxbyqxzbhxcpxxtnzdnnycnxsxlhkmzxlthdhkghxxsshqyhh"
"cjyxglhzxcxnhekdtgqxqypkdhentykcnymyyjmkqyyyjxzlthhqtbyqhxbmyhsqckwwyllhcyylnneqxqwmcfbdccmljggxdqkt"
"lxkknqcdgcjwyjjlyhhqyttnwchhxcxwherzjydjccdbqcdgdnyxzdhcqrxcbhztqcbxwgqwyybxhmbymykdyecmqkyaqyngyzsl"
"fnkkqgyssqyshngjctxkzycssbkyxhyylstycxqthysmnscpmmgcccccmnztasmgqzjhklosjylswtmqzyqkdzljqqyplzycztcq"
"qpbbcjzclpkhqcyyxxdtdddsjcxffllchqxmjlwcjcxtspycxndtjshjwhdqqqckxyamylsjhmlalygxcyydmamdqmlmcznnyybz"
"xkyflmcncmlhxrcjjhsylnmtjggzgywjxsrxcwjgjqhqzdqjdcjjskjkgdzcgjjyjylxzxxcdqhhheslmhlfsbdjsyyshfyssczq"
"lpbdrfnztzdkykhsccgkwtqzckmsynbcrxqbjyfaxpzzedzcjykbcjwhyjbqzzywnyszptdkzpfpbaztklqnhbbzptpptyzzybhn"
"ydcpzmmcycqmcjfzzdcmnlfpbplngqjtbttajzpzbbdnjkljqylnbzqhksjznggqstzkcxchpzsnbcgzkddzqanzgjkdrtlzldwj"
"njzlywtxndjzjhxnatncbgtzcsskmljpjytsnwxcfjwjjtkhtzplbhsnjssyjbhbjyzlstlsbjhdnwqpslmmfbjdwajyzccjtbnn"
"nzwxxcdslqgdsdpdzgjtqqpsqlyyjzlgyhsdlctcbjtktyczjtqkbsjlgnnzdncsgpynjzjjyyknhrpwszxmtncszzyshbyhyzax"
"ywkcjtllckjjtjhgcssxyqyczbynnlwqcglzgjgqyqcczssbcrbcskydznxjsqgxssjmecnstjtpbdlthzwxqwqczexnqczgwesg"
"ssbybstscslccgbfsdqnzlccglllzghzcthcnmjgyzazcmsksstzmmzckbjygqljyjppldxrkzyxccsnhshhdznlzhzjjcddcbcj"
"xlbfqbczztpqdnnxljcthqzjgylklszzpcjdscqjhjqkdxgpbajynnsmjtzdxlcjyryynhjbngzjkmjxltbsllrzpylssznxjhll"
"hyllqqzqlsymrcncxsljmlzltzldwdjjllnzggqxppskyggggbfzbdkmwggcxmcgdxjmcjsdycabxjdlnbcddygskydqdxdjjyxh"
"saqazdzfslqxxjnqzylblxxwxqqzbjzlfbblylwdsljhxjyzjwtdjcyfqzqzzdzsxzzqlzcdzfxhwspynpqzmlpplffxjjnzzyls"
"jnyqzfpfzgsywjjjhrdjzzxtxxglghtdxcskyswmmtcwybazbjkshfhgcxmhfqhyxxyzftsjyzbxyxpzlchmzmbxhzzssyfdmncw"
"dabazlxktcshhxkxjjzjsthygxsxyyhhhjwxkzxssbzzwhhhcwtzzzpjxsyxqqjgzyzawllcwxznxgyxyhfmkhydwsqmnjnaycys"
"pmjkgwcqhylajgmzxhmmcnzhbhxclxdjpltxyjkdyylttxfqzhyxxsjbjnayrsmxyplckdnyhlxrlnllstycyyqygzhhsccsmcct"
"zcxhyqfpyyrpbflfqnntszlljmhwtcjqyzwtlnmlmdwmbzzsnzrbpdddlqjjbxtcsnzqqygwcsxfwzlxccrszdzmcyggdyqsgtnn"
"nlsmymmsyhfbjdgyxccpshxczcsbsjyygjmpbwaffyfnxhydxzylremzgzzyndsznlljcsqfnxxkptxzgxjjgbmyyssnbtylbnlh"
"bfzdcyfbmgqrrmzszxysjtznnydzzcdgnjafjbdknzblczszpsgcycjszlmnrznbzzldlnllysxsqzqlcxzlsgkbrxbrbzcycxzj"
"zeeyfgklzlnyhgzcgzlfjhgtgwkraajyzkzqtsshjjxdzyznynnzyrzdqqhgjzxsszbtkjbbfrtjxllfqwjgclqtymblpzdxtzag"
"bdhzzrbgjhwnjtjxlkscfsmwlldcysjtxkzscfwjlbnntzlljzllqblcqmqqcgcdfpbphzczjlpyyghdtgwdxfczqyyyqysrclqz"
"fklzzzgffcqnwglhjycjjczlqzzyjbjzzbpdcsnnjgxdqnknlznnnnpsntsdyfwwdjzjysxyyczcyhzwbbyhxrylybhkjksfxtjj"
"mmchhlltnyymsxxyzpdjjycsycwmdjjkqyrhllngpngtlyycljnnnxjyzfnmlrgjjtyzbsyzmsjyjhgfzqmsyxrszcytlrtqzsst"
"kxgqkgsptgxdnjsgcqcqhmxggztqydjjznlbznxqlhyqgggthqscbyhjhhkyygkggcmjdzllcclxqsftgjslllmlcskctbljszsz"
"mmnytpzsxqhjcnnqnyexzqzcpshkzzyzxxdfgmwqrllqxrfztlystctmjcsjjthjnxtnrztzfqrhcgllgcnnnnjdnlnnytsjtlny"
"xsszxcgjzyqpylfhdjsbbdczgjjjqzjqdybssllcmyttmqnbhjqmnygjyeqyqmzgcjkpdcnmyzgqllslnclmholzgdylfzslncnz"
"lylzcjeshnyllnxnjxlyjyyyxnbcljsswcqqnnyllzldjnllzllbnylnqchxyyqoxccqkyjxxxyklksxeyqhcqkkkkcsnyxxyqxy"
"gwtjohthxpxxhsnlcykychzzcbwqbbwjqcscszsslcylgddsjzmmymcytsdsxxscjpqqsqylyfzychdjynywcbtjsydchcyddjlb"
"djjsodzyqyskkyxdhhgqjyohdyxwgmmmazdybbbppbcmnnpnjzsmtxerxjmhqdntpjdcbsnmssythjtslmltrcplzszmlqdsdmjm"
"qpnqdxcfrnnfsdqqyxhyaykqyddlqyyysszbydslntfgtzqbzmchdhczcwfdxtmqqsphqwwxsrgjcwnntzcqmgwqjrjhtqjbbgwz"
"fxjhnqfxxqywyyhyscdydhhqmrmtmwctbszppzzglmzfollcfwhmmsjzttdhlmyffytzzgzyskjjxqyjzqbhmbzclyghgfmshpcf"
"zsnclpbqsnjyzslxxfpmtyjygbxlldlxpzjyzjyhhzcywhjylsjexfszzywxkzjlnadymlymqjpwxxhxsktqjezrpxxzghmhwqpw"
"qlyjjqjjzszcnhjlchhnxjlqwzjhbmzyxbdhhypylhlhlgfwlcfyytlhjjcwmscpxstkpnhjxsntyxxtestjctlsslstdlllwwyh"
"dnrjzsfgxssyczykwhtdhwjglhtzdqdjzxxqgghltzphcsqfclnjtclzpfstpdynylgmjllycqhynspchylhqyqtmzymbywrfqyk"
"jsyslzdnjmpxyyssrhzjnyqtqdfzbwwdwwrxcwggyhxmkmyyyhmxmzhnksepmlqqmtcwctmxmxjpjjhfxyyzsjzhtybmstsyjznq"
"jnytlhynbyqclcycnzwsmylknjxlggnnpjgtysylymzskttwlgsmzsylmpwlcwxwqcssyzsyxyrhssntsrwpccpwcmhdhhxzdzyf"
"jhgzttsbjhgyglzysmyclllxbtyxhbbzjkssdmalhhycfygmqypjyjqxjllljgclzgqlycjcctotyxmtmshllwlqfxymzmklpszz"
"cxhkjyclctyjcyhxsgyxnnxlzwpyjpxhjwpjpwxqqxlxsdhmrslzzydwdtcxknstzshbsccstplwsscjchjlcgchssphylhfhhxj"
"sxallnylmzdhzxylsxlmzykcldyahlcmddyspjtqjzlngjfsjshctsdszlblmssmnyymjqbjhrzwtyydchjljapzwbgqxbkfnbjd"
"llllyylsjydwhxpsbcmljpscgbhxlqhyrljxyswxhhzlldfhlnnymjljyflyjycdrjlfsyzfsllcqyqfgqyhnszlylmdtdjcnhbz"
"llnwlqxygyyhbmgdhxxnhlzzjzxczzzcyqzfngwpylcpkpykpmclgkdgxzgxwqbdxzzkzfbddlzxjtpjpttbythzzdwslcpnhslt"
"jxxqlhyxxxywzyswttzkhlxzxzpyhgzhknfsyhntjrnxfjcpjztwhplshfcrhnslxxjxxyhzqdxqwnnhyhmjdbflkhcxcwhjfyjc"
"fpqcxqxzyyyjygrpynscsnnnnchkzdyhflxxhjjbyzwttxnncyjjymswyxqrmhxzwfqsylznggbhyxnnbwttcsybhxxwxyhhxyxn"
"knyxmlywrnnqlxbbcljsylfsytjzyhyzawlhorjmnsczjxxxyxchcyqryxqzddsjfslyltsffyxlmtyjmnnyyyxltzcsxqclhzxl"
"wyxzhnnlrxkxjcdyhlbrlmbrdlaxksnlljlyxxlynrylcjtgncmtlzllcyzlpzpzyawnjjfybdyyzsepckzzqdqpbpsjpdyttbdb"
"bbyndycncpjmtmlrmfmmrwyfbsjgygsmdqqqztxmkqwgxllpjgzbqrdjjjfpkjkcxbljmswldtsjxldlppbxcwkcqqbfqbccajzg"
"mykbhyhhzykndqzybpjnspxthlfpnsygyjdbgxnhhjhzjhstrstldxskzysybmxjlxyslbzyslzxjhfybqnbylljqkygzmcyzzym"
"ccslnlhzhwfwyxzmwyxtynxjhbyymcysbmhysmydyshnyzchmjjmzcaahcbjbbhblytylsxsnxgjdhkxxtxxnbhnmlngsltxmrhn"
"lxqqxmzllyswqgdlbjhdcgjyqyymhwfmjybbbyjyjwjmdpwhxqldyapdfxxbcgjspckrssyzjmslbzzjfljjjlgxzgyxyxlszqkx"
"bexyxhgcxbpndyhwectwwcjmbtxchxyqqllxflyxlljlssnwdbzcmyjclwswdczpchqekcqbwlcgydblqppqzqfnqdjhymmcxtxd"
"rmzwrhxcjzylqxdyynhyyhrslnrsywwjjymtltllgtqcjzyabtckzcjyccqlysqxalmzynywlwdnzxqdllqshgpjfjljnjabcqzd"
"jgthhsstnyjfbswzlxjxrhgldlzrlzqzgsllllzlymxxgdzhgbdphzpbrlwnjqbpfdwonnnhlypcnjccndmbcpbzzncyqxldomzb"
"lzwpdwyygdstthcsqsccrsssyslfybnntyjszdfndpdhtqzmbqlxlcmyffgtjjqwftmnpjwdnlbzcmmcngbdzlqlpnfhyymjylsd"
"chdcjwjcctljcldtljjcbddpndsszycndbjlggjzxsxnlycybjjxxcbylzcfzppgkcxqdzfztjjfjdjxzbnzyjqctyjwhdyczhym"
"djxttmpxsplzcdwslshxypzgtfmlcjtacbbmgdewycyzxdszjyhflystygwhkjyylsjcxgywjcbllcsnddbtzbsclyzczzssqdll"
"mjyyhfllqllxfdyhabxggnywyypllsdldllbjcyxjznlhljdxyyqytdlllbngpfdfbbqbzzmdpjhgclgmjjpgaehhbwcqxajhhhz"
"chxyphjaxhlphjpgpzjqcqzgjjzzgzdmqyybzzphyhybwhazyjhykfgdpfqsdlzmljxjpgalxzdaglmdgxmmzqwtxdxxpfdmmssy"
"mpfmdmmkxksyzyshdzkjsysmmzzzmdydyzzczxbmlstmdyemxckjmztyymzmzzmsshhdccjewxxkljsthwlsqlyjzllsjssdppmh"
"nlgjczyhmxxhgncjmdhxtkgrmxfwmckmwkdcksxqmmmszzydkmsclcmpcjmhrpxqpzdsslcxkyxtwlkjyahzjgzjwcjnxyhmmbml"
"gjxmhlmlgmxctkzmjlyscjsyszhsyjzjcdajzhbsdqjzgwtkqxfkdmsdjlfmnhkzqkjfeypzyszcdpynffmzqykttdzzefmzlbnp"
"plplpbpszalltnlkckqzkgenjlwalkxydpxnhsxqnwqnkxqclhyxxmlnccwlymqyckynnlcjnszkpyzkcqzqljbdmdjhlasqlbyd"
"wqlwdgbqcryddztjybkbwszdxdtnpjdtcnqnfxqqmgnseclstbhpwslctxxlpwydzklnqgzcqapllkqcylbqmqczqcnjslqzdjxl"
"ddhpzqdljjxzqdjyzhhzlkcjqdwjppypqakjyrmpzbnmcxkllzllfqpylllmbsglzysslrsysqtmxyxzqzbscnysyztffmzzsmzq"
"hzssccmlyxwtpzgxzjgzgsjzgkddhtqggzllbjdzlsbzhyxyzhzfywxytymsdnzzyjgtcmtnxqyxjscxhslnndlrytzlryylxqht"
"xsrtzcgyxbnqqzfhykmzjbzymkbpnlyzpblmcnqyzzzsjztjctzhhyzzjrdyzhnfxklfzslkgjtctssyllgzrzbbjzzklpkbczys"
"nnyxbjfbnjzzxcdwlzyjxzzdjjgggrsnjkmsmzjlsjywqsnyhqjsxpjztnlsnshrnynjtwchglbnrjlzxwjqxqkysjycztlqzybb"
"ybyzjqdwgyzcytjcjxckcwdkkzxsnkdnywwyyjqyytlytdjlxwkcjnklccpzcqqdzzqlcsfqchqqgssmjzzllbjjzysjhtsjdysj"
"qjpdszcdchjkjzzlpycgmzndjxbsjzzsyzyhgxcpbjydssxdzncglqmbtsfcbfdzdlznfgfjgfsmpnjqlnblgqcyyxbqgdjjqsrf"
"kztjdhczklbsdzcfytplljgjhtxzcsszzxstjygkgckgynqxjplzbbbgcgyjzgczqszlbjlsjfzgkqqjcgycjbzqtldxrjnbsxxp"
"zshszycfwdsjjhxmfczpfzhqhqmqnknlyhtycgfrzgnqxcgpdlbzcsczqlljblhbdcypscppdymzzxgyhckcpzjgslzlnscnsldl"
"xbmsdlddfjmkdqdhslzxlsznpqpgjdlybdskgqlbzlnlkyyhzttmcjnqtzzfszqktlljtyyllnllqyzqlbdzlslyyzxmdfszsnxl"
"xznczqnbbwskrfbcylctnblgjpmczzlstlxshtzcyzlzbnfmqnlxflcjlyljqcbclzjgnsstbrmhxzhjzclxfnbgxgtqncztmsfz"
"kjmssncljkbhszjntnlzdntlmmjxgzjyjczxyhyhwrwwqnztnfjscpyshzjfyrdjsfscjzbjfzqzchzlxfxsbzqlzsgyftzdcszx"
"zjbjpszkjrhxjzcgbjkhcggtxkjqglxbxfgtrtylxqxhdtsjxhjzjjcmzlcqsbtxwqgxtxxhxftsdkfjhzyjfjxnzldlllcqsqqz"
"qwqxswqtwgwbzcgcllqzbclmqjtzgzyzxljfrmyzflxnsnxxjkxrmjdzdmmyxbsqbhgzmwfwygmjlzbyytgzyccdjyzxsngnyjyz"
"nbgpzjcqsyxsxrtfyzgrhztxszzthcbfclsyxzlzqmzlmplmxzjssfsbysmzqhxxnxrxhqzzzsslyflczjrcrxhhzxqndshxsjjh"
"qcjjbcynsysxjbqjpxzqplmlxzkyxlxcnlcycxxzzlxdlllmjyhzxhyjwkjrwyhcpsgnrzlfzwfzznsxgxflzsxzzzbfcsyjdbrj"
"krdhhjxjljjtgxjxxstjtjxlyxqfcsgswmsbctlqzzwlzzkxjmltmjyhsddbxgzhdlbmyjfrzfcgclyjbpmlysmsxlszjqqhjzfx"
"gfqfqbphngyyqxgztnqwyltlgwgwwhnlfmfgzjmgmgbgtjflyzzgzyzaflsspmlbflcwbjztljjmzlpjjlymqtmyyyfbgygqzgly"
"zdxqyxrqqqhsxyyqxygjtyxfsfsllgnqcygycwfhcccfxpylypllzqxxxxxqqhhsshjzcftsczjxspzwhhhhhapylqnlpqafyhxd"
"ylnkmzqgggddesrenzltzgchyppcsqjjhclljtolnjpzljlhymhezdydsqycddhgznndzclzywllznteydgnlhslpjjbdgwxpcnn"
"tycklkclwkllcasstknzdnnjttlyyzssysszzryljqkcgdhhyrxrzydgrgcwcgzqffbppjfzynakrgywyjpqxxfkjtszzxswzddf"
"bbqtbgtzkznpzfpzxzpjszbmqhkyyxyldkljnypkyghgdzjxxeaxpnznctzcmxcxmmjxnkszqnmnlwbwwqjjyhclstmcsxnjcxxt"
"pcnfdtnnpglllzcjlspblpgjcdtnjjlyarscffjfqwdpgzdwmrzzcgodaxnssnyzrestyjwjyjdbcfxnmwttbqlwstszgybljpxg"
"lbnclgpcbjftmxzljylzxcltpnclcgxtfzjshcrxsfysgdkntlbyjcyjllstgqcbxnhzxbxklylhzlqzlnzcqwgzlgzjncjgcmnz"
"zgjdzxtzjxycyycxxjyyxjjxsssjstsstdppghtcsxwzdcsynptfbchfbblzjclzzdbxgcjlhpxnfzflsyltnwbmnjhszbmdnbcy"
"sccldnycndqlyjjhmqllcsgljjsyfpyyccyltjantjjpwycmmgqyysxdxqmzhszxbftwwzqswqrfkjlzjqqyfbrxjhhfwjgzyqac"
"myfrhcyybynwlpexcczsyyrlttdmqlrkmpbgmyyjprkznbbsqyxbhyzdjdnghpmfsgbwfzmfqmmbzmzdcgjlnnnxyqgmlrygqccy"
"xzlwdkcjcggmcjjfyzzjhycfrrcmtznzxhkqgdjxccjeascrjthpljlrzdjrbcqhjdnrhylyqjsymhzydwcdfryhbbydtssccwbx"
"glpzmlzjdqsscfjmmxjcxjytycghycjwynsxlfemwjnmkllswtxhyyyncmmcyjdqdjzglljwjnkhpzggflccsczmcbltbhbqjxqd"
"jpdjztghglfjawbzyzjltstdhjhctcbchflqmpwdshyytqwcnntjtlnnmnndyyyxsqkxwyyflxxnzwcxypmaelyhgjwzzjbrxxaq"
"jfllpfhhhytzzxsgqjmhspgdzqwbwpjhzjdyjcqwxkthxsqlzyymysdzgnqckknjlwpnsyscsyzlnmhqsyljxbcxtlhzqzpcycyk"
"pppnsxfyzjjrcemhszmnxlxglrwgcstlrsxbygbzgnxcnlnjlclynymdxwtzpalcxpqjcjwtcyyjlblxbzlqmyljbghdslssdmxm"
"bdczsxyhamlczcpjmcnhjyjnsykchskqmczqdllkablwjqsfmocdxjrrlyqchjmybyqlrhetfjzfrfksryxfjdwtsxxywsqjysly"
"xwjhsdlxyyxhbhawhwjcxlmyljcsqlkydttxbzslfdxgxsjkhsxxybssxdpwncmrptqzczenygcxqfjxkjbdmljzmqqxnoxslyxx"
"lylljdzptymhbfsttqqwlhsgynlzzalzxclhtwrrqhlstmypyxjjxmnsjnnbryxyjllyqyltwylqyfmlkljdnlltfzwkzhljmlhl"
"jnljnnlqxylmbhhlnlzxqchxcfxxlhyhjjgbyzzkbxscqdjqdsndzsygzhhmgsxcsymxfepcqwwrbpyyjqryqcyjhqqzyhmwffhg"
"zfrjfcdbxntqyzpcyhhjlfrzgpbxzdbbgrqstlgdgylcqmgchhmfywlzyxkjlypjhsywmqqggzmnzjnsqxlqsyjtcbehsxfszfxz"
"wfllbcyyjdytdthwzsfjmqqyjlmqsxlldttkghybfpwdyysqqrnqwlgwdebzwcyygcnlkjxtmxmyjsxhybrwfymwfrxyymxysctz"
"ztfykmldhqdlgyjnlcryjtlpsxxxywlsbrrjwxhqybhtydnhhxmmywytycnnmnssccdalwztcpqpyjllqzyjswjwzzmmglmxclmx"
"nzmxmzsqtzppjqblpgxjzhfljjhycjsrxwcxsncdlxsyjdcqzxslqyclzxlzzxmxqrjmhrhzjbhmfljlmlclqnldxzlllfyprgjy"
"nxcqqdcmqjzzxhnpnxzmemmsxykynlxsxtljxyhwdcwdzhqyybgybcyscfgfsjnzdrzzxqxrzrqjjymcanhrjtldbpyzbstjhxxz"
"ypbdwfgzzrpymnnkxcqbyxnbnfyckrjjcmjegrzgyclnnzdnkknsjkcljspgyyclqqjybzssqlllkjftbgtylcccdblsppfylgyd"
"tzjqjzgkntsfcxbdkdxxhybbfytyhbclnnytgdhryrnjsbtcsnyjqhklllzslydxxwbcjqsbxnpjzjzjdzfbxxbrmladhcsnclbj"
"dstblprznswsbxbcllxxlzdnzsjpynyxxyftnnfbhjjjgbygjpmmmmsszljmtlyzjxswxtyledqpjmpgqzjgdjlqjwjqllsdgjgy"
"gmscljjxdtygjqjjjcjzcjgdzdshqgzjggcjhqxsnjlzzbxhsgzxcxyljxyxyydfqqjhjfxdhctxjyrxysqtjxyefyyssyxjxncy"
"zxfxcsxszxyyschshxzzzgzzzgfjdldylnpzgsjaztyqzpbxcbdztzczyxxyhhscjshcggqhjhgxhsctmzmehyxgebtclzkkwytj"
"zrslekestdbcyhqqsayxcjxwwgsphjszsdncsjkqcxswxfctynydpccczjqtcwjqjzzzqzljzhlsbhpydxpsxshhezdxfptjqyzc"
"xhyaxncfzyyhxgnqmywntzsjbnhhgymxmxqcnssbcqsjyxxtyyhybcqlmmszmjzzllcogxzaajzyhjmchhcxzsxsdznleyjjzjbh"
"zwjzsqtzpsxzzdsqjjjlnyazphhyysrnqzthzhnyjyjhdzxzlswclybzyecwcycrylchzhzydzydyjdfrjjhtrsqtxyxjrjhojyn"
"xelxsfsfjzghpzsxzszdzcqzbyyklsgsjhczshdgqgxyzgxchxzjwyqwgyhksseqzzndzfkwyssdclzstsymcdhjxxyweyxczayd"
"mpxmdsxybsqmjmzjmtjqlpjyqzcgqhyjhhhqxhlhdldjqcfdwbsxfzzyyschtytyjbhecxhjkgqfxbhyzjfxhwhbdzfyzbchpnpg"
"dydmsxhkhhmamlnbyjtmpxejmcthqbzyfcgtyhwphftgzzezsbzegpbmdskftycmhbllhgpzjxzjgzjyxzsbbqsczzlzscstpgxm"
"jsfdcczjzdjxsybzlfcjsazfgszlwbczzzbyztzynswyjgxzbdsynxlgzbzfygczxbzhzftpbgzgejbstgkdmfhyzzjhzllzzgjq"
"zlsfdjsscbzgpdlfzfzszyzyzsygcxsnxxchczxtzzljfzgqsqqxcjqccccdjcdszzyqjccgxztdlgscxzsyjjqtcclqdqztqchq"
"qyzynzzzpbkhdjfcjfztypqyqttynlmbdktjcpqzjdzfpjsbnjlgyjdxjdcqkzgqkxclbzjtcjdqbxdjjjstcxnxbxqmslyjcxnt"
"jqwwcjjnjjlllhjcwqtbzqqczczpzzdzyddcyzdzccjgtjfzdprntctjdcxtqzdtjnplzbcllctdsxkjzqdmzlbznbtjdcxfczdb"
"czjjltqqpldckztbbzjcqdcjwynllzlzccdwllxwzlxrxntqjczxkjlsgdnqtddglnlajjtnnynkqlldzntdnycygjwyxdxfrsqs"
"tcdenqmrrqzhhqhdldazfkapbggpzrebzzykyqspeqjjglkqzzzjlysyhyzwfqznlzzlzhwcgkypqgnpgblplrrjyxcccgyhsfzf"
"wbzywtgzxyljczwhncjzplfflgskhyjdeyxhlpllllcygxdrzelrhgklzzyhzlyqszzjzqljzflnbhgwlczcfjwspyxzlzlxgccp"
"zbllcxbbbbnbbcbbcrnnzccnrbbnnldcgqyyqxygmqzwnzytyjhyfwtehznjywlccntzyjjcdedpwdztstnjhtymbjnyjzlxtsst"
"phndjxxbyxqtzqddtjtdyztgwscszqflshlnzbcjbhdlyzjyckwtydylbnydsdsycctyszyyebgexhqddwnygyclxtdcystqnygz"
"ascsszzdzlcclzrqxyywljsbymxshzdembbllyyllytdqyshymrqnkfkbfxnnsbychxbwjyhtqbpbsbwdzylkgzskyghqzjxhxjx"
"gnljkzlyycdxlfwfghljgjybxblybxqpqgntzplncybxdjyqydymrbeyjyyhkxxstmxrczzjwxyhybmcflyzhqyzfwxdbxbcwzms"
"lpdmyckfmzklzcyqycclhxfzlydqzpzygyjyzmdxtzfnnyttqtzhgsfcdmlccytzxjcytjmkslpzhysnwllytpzctzccktxdhxxt"
"qcyfksmqccyyazhtjplylzlyjbjxtfnyljyynrxcylmmnxjsmybcsysslzylljjgyldzdlqhfzzblfndsqkczfyhhgqmjdsxyctt"
"xnqnjpyybfcjtyyfbnxejdgyqbjrcnfyyqpghyjsyzngrhtknlnndzntsmgklbygbpyszbydjzsstjztsxzbhbscsbzczptqfzlq"
"flypybbjgszmnxdjmtsyskkbjtxhjcegbsmjyjzcstmljyxrczqscxxqpyzhmkyxxxjcljyrmyygadyskqlnadhrskqxzxztcggz"
"dlmlwxybwsyctbhjhcfcwzsxwwtgzlxqshnyczjxemplsrcgltnzntlzjcyjgdtclglbllqpjmzpapxyzlaktkdwczzbncctdqqz"
"qyjgmcdxltgcszlmlhbglkznnwzndxnhlnmkydlgxdtwcfrjerctzhydxykxhwfzcqshknmqqhzhhymjdjskhxzjzbzzxympajnm"
"ctbxlsxlzynwrtsqgscbptbsgzwyhtlkssswhzzlyytnxjgmjrnsnnnnlskztxgxlsammlbwldqhylakqcqctmycfjbslxclzjcl"
"xxknbnnzlhjphqplsxsckslnhpsfqcytxjjzljldtzjjzdlydjntptnndskjfsljhylzqqzlbthydgdjfdbyadxdzhzjnthqbykn"
"xjjqczmlljzkspldsclbblnnlelxjlbjycxjxgcnlcqplzlznjtsljgyzdzpltqcssfdmnycxgbtjdcznbgbqyqjwgkfhtnbyqzq"
"gbkpbbyzmtjdytblsqmbsxtbnpdxklemyycjynzdtldykzzxtdxhqshygmzsjycctayrzlpwltlkxslzcggexclfxlkjrtlqjaqz"
"ncmbqdkkcxglczjzxjhptdjjmzqykqsecqzdshhadmlzfmmzbgntjnnlhbyjbrbtmlbyjdzxlcjlpldlpcqdhlhzlycblcxccjad"
"qlmzmmsshmybhbnkkbhrsxxjmxmdznnpklbbrhgghfchgmnklltsyyycqlcskymyehywxnxqywbawykqldnntndkhqcgdqktgpkx"
"hcpdhtwnmssyhbwcrwxhjmkmzngwtmlkfghkjyldyycxwhyyclqhkqhtdqkhffldxqwytyydesbpkyrzpjfyyzjceqdzzdlattpb"
"fjllcxdlmjsdxegwgsjqxcfbssszpdyzcxznyxppzydlyjccpltxlnxyzyrscyyytylwwndsahjsygyhgywwaxtjzdaxysrltdps"
"syxfnejdxyzhlxlllzhzsjnyqyqyxyjghzgjcyjchzlycdshhsgczyjscllnxzjjyyxnfsmwfpyllyllabmddhwzxjmcxztzpmlq"
"chsfwzynctlndywlslxhymmylmbwwkyxyaddxylldjpybpwnxjmmmllhafdllaflbnhhbqqjqzjcqjjdjtffkmmmpythygdrjrdd"
"wrqjxnbysrmzdbyytbjhpymyjtjxaahggdqtmystqxkbtzbkjlxrbyqqhxmjjbdjntgtbxpgbktlgqxjjjcdhxqdwjlwrfmjgwqh"
"cnrxswgbtgygbwhswdwrfhwytjjxxxjyzyslphyypyyxhydqpxshxyxgskqhywbdddpplcjlhqeewjgsyykdpplfjthkjltcyjhh"
"jttpltzzcdlyhqkcjqysteeyhkyzyxxyysddjkllpymqyhqgxqhzrhbxpllnqydqhxsxxwgdqbshyllpjjjthyjkyphthyyktyez"
"yenmdshlzrpqfbnfxzbsftlgxsjbswyysksflxlpplbbblnsfbfyzbsjssylpbbffffsscjdstjsxtryjcyffsyzyzbjtlctsbsd"
"hrtjjbytcxyyeylycbnebjdsysyhgsjzbxbytfzwgenhhhthjhhxfwgcstbgxklstyymtmbyxjskzscdyjrcythxzfhmymcxlzns"
"djtxtxrycfyjsbsdyerxhljxbbdeynjghxgckgscymblxjmsznskgxfbnbbthfjyafxwxfbxmyfhdttcxzzpxrsywzdlybbktyqw"
"qjbzypzjznjpzjlztfysbttslmptzrtdxqsjehbnylndxljsqmlhtxtjecxalzzspktlzkqqyfsyjywpcpqfhjhytqxzkrsgtksq"
"czlptxcdyyzsslzslxlzmacpcqbzyxhbsxlzdltztjtylzjyytbzypltxjsjxhlbmytxcqrblzssfjzztnjytxmyjhlhpblcyxqj"
"qqkzzscpzkswalqsplczzjsxgwwwygyatjbbctdkhqhkgtgpbkqyslbxbbckbmllndzstbklggqkqlzbkktfxrmdkbftpzfrtppm"
"ferqnxgjpzsstlbztpszqzsjdhljqlzbpmsmmsxlqqnhknblrddnhxdkddjcyyljfqgzlgsygmjqjkhbpmxyxlytqwlwjcpbmjxc"
"yzydrjbhtdjyeqshtmgsfyplwhlzffnynnhxqhpltbqpfbjwjdbygpnxtbfzjgnnntjshxeawtzylltyqbwjpgxghnnkndjtmszs"
"qynzggnwqtfhclssgmnnnnynzqqxncjdqgzdlfnykljcjllzlmzznnnnsshthxjlzjbbhqjwwycrdhlyqqjbeyfsjhthnrnwjhwp"
"slmssgzttygrqqwrnlalhmjtqjsmxqbjjzjqzyzkxbjqxbjxshzssfglxmxnxfghkzszggslcnnarjxhnlllmzxelglxydjytlfb"
"kbpnlyzfbbhptgjkwetzhkjjxzxxglljlstgshjjyqlqzfkcgnndjsszfdbctwwseqfhqjbsaqtgypjlbxbmmywxgslzhglsgnyf"
"ljbyfdjfngsfmbyzhqffwjsyfyjjphzbyyzffwotjnlmftwlbzgyzqxcdjygzyyryzynyzwegazyhjjlzrthlrmgrjxzclnnnljj"
"yhtbwjybxxbxjjtjteekhwslnnlbsfazpqqbdlqjjtyyqlyzkdksqjnejzldqcgjqnnjsncmrfqthtejmfctyhypymhydmjncfgy"
"yxwshctxrljgjzhzcyyyjltkttntmjlzclzzayyoczlrlbszywjytsjyhbyshfjlykjxxtmzyyltxxypslqyjzyzyypnhmymdyyl"
"blhlsyygqllnjjymsoycbzgdlyxylcqyxtszegxhzglhwbljheyxtwqmakbpqcgyshhegqcmwyywljyjhyyzlljjylhzyhmgsljl"
"jxcjjyclycjbcpzjzjmmwlcjlnqljjjlxyjmlszljqlycmmgcfmmfpqqmfxlqmcffqmmmmhnznfhhjgtthxkhslnchhyqzxtmmqd"
"cydyxyqmyqylddcyaytazdcymdydlzfffmmycqcwzzmabtbyctdmndzggdftypcgqyttssffwbdttqssystwnjhjytsxxylbyyhh"
"whxgzxwznnqzjzjjqjccchykxbzszcnjtllcqxynjnckycynccqnxyewyczdcjycchyjlbtzyycqwlpgpyllgktltlgkgqbgychj"
"xy";

#pragma mark - NSString+Extend
@interface NSMutableString (TagReplace)
- (void)replaceAllTagsIntoArray:(NSMutableArray*)array;
@end
@implementation NSMutableString (TagReplace)
- (BOOL)replaceFirstTagItoArray:(NSMutableArray*)array{
	NSRange openTagRange = [self rangeOfString:@"<"];
	if (openTagRange.length == 0) return NO;
	NSRange closeTagRange = [self rangeOfString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(openTagRange.location+openTagRange.length, self.length-(openTagRange.location+openTagRange.length))];
	if (closeTagRange.length == 0) return NO;
	NSRange range = NSMakeRange(openTagRange.location, closeTagRange.location-openTagRange.location+1);
	NSString *tag = [self substringWithRange:range];
	[self replaceCharactersInRange:range withString:@""];
	BOOL isEndTag = [tag rangeOfString:@"</"].length == 2;
	if (isEndTag) {
		NSString *openTag = [tag stringByReplacingOccurrencesOfString:@"</" withString:@"<"];
		NSInteger count = array.count;
		for (NSInteger i=count-1; i>=0; i--) {
			NSDictionary *dict = array[i];
			__block NSString *attr = @"";
			NSString *dtag = [dict[@"tag"] preg_replace:@"<(\\w+)([^>]*)>" replacement:^NSString *(NSDictionary *matcher, NSInteger index) {
				attr = [matcher[@"group"][1] trim];
				return [NSString stringWithFormat:@"<%@>", matcher[@"group"][0]];
			}];
			if ([dtag isEqualToString:openTag]) {
				NSNumber *loc = dict[@"loc"];
				if ([loc integerValue] < range.location) {
					[array removeObjectAtIndex:i];
					NSString *strippedTag = [openTag substringWithRange:NSMakeRange(1, openTag.length-2)];
					NSString *text = [self substringWithRange:NSMakeRange(loc.integerValue, range.location-loc.integerValue)];
					[array addObject:@{@"loc":loc, @"tag":strippedTag, @"attr":attr, @"endloc":@(range.location), @"text":text}];
				}
				break;
			}
		}
	} else {
		[array addObject:@{@"loc":@(range.location), @"tag":tag}];
	}
	return YES;
}
- (void)replaceAllTagsIntoArray:(NSMutableArray*)array{
	while ([self replaceFirstTagItoArray:array]) {}
}
@end

@implementation NSString (GlobalExtend)

//获取本地储存
- (id)getUserDefaults{
	id obj = [[NSUserDefaults standardUserDefaults] valueForKey:self];
	if ([obj isKindOfClass:[NSString class]] && ![obj length]) obj = @"";
	return obj;
}
- (NSString*)getUserDefaultsString{
	NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:self];
	if (!string.length) string = @"";
	return string;
}
- (int)getUserDefaultsInt{
	id data = [self getUserDefaults];
	if (![data isInt]) return 0;
	return [data intValue];
}
- (NSInteger)getUserDefaultsInteger{
	return [[NSUserDefaults standardUserDefaults] integerForKey:self];
}
- (CGFloat)getUserDefaultsFloat{
	return [[NSUserDefaults standardUserDefaults] floatForKey:self];
}
- (BOOL)getUserDefaultsBool{
	return [[NSUserDefaults standardUserDefaults] boolForKey:self];
}
- (NSMutableArray*)getUserDefaultsArray{
	NSArray *data = [[NSUserDefaults standardUserDefaults] arrayForKey:self];
	if (data) {
		return [NSMutableArray arrayWithArray:data];
	} else {
		return [[NSMutableArray alloc]init];
	}
}
- (NSMutableDictionary*)getUserDefaultsDictionary{
	NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:self];
	if (data) {
		return [NSMutableDictionary dictionaryWithDictionary:data];
	} else {
		return [[NSMutableDictionary alloc]init];
	}
}

//保存到本地储存
- (void)setUserDefaultsWithData:(id)data{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:self];
	[userDefaults setObject:data forKey:self];
	[userDefaults synchronize];
}

//替换本地储存某些key的值
- (void)replaceUserDefaultsWithData:(NSDictionary*)data{
	NSMutableDictionary *dict = [self getUserDefaultsDictionary];
	if (!dict) dict = [[NSMutableDictionary alloc]init];
	for (NSString *key in data) {
		[dict setObject:data[key] forKey:key];
	}
	[self setUserDefaultsWithData:dict];
}

//删除本地储存
- (void)deleteUserDefaults{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:self];
	[userDefaults synchronize];
}

//自动宽度
- (CGSize)autoWidth:(UIFont*)font height:(CGFloat)height{
	if (!self.length) return CGSizeMake(0, height);
	NSString *text = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]] componentsJoinedByString:@""];
	NSDictionary *attributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:COLORTEXT};
	NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
	CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:options attributes:attributes context:NULL];
	CGSize size = CGSizeMake(rect.size.width, rect.size.height);
	return size;
	//NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	//[paragraphStyle setLineBreakMode:NSLineBreakByClipping];
	//[paragraphStyle setAlignment:NSTextAlignmentCenter];
	//NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle };
	//[str drawInRect:CGRectMake(0, 0, MAXFLOAT, height) withAttributes:attributes];
}

//自动高度
- (CGSize)autoHeight:(UIFont*)font width:(CGFloat)width{
	if (!self.length) return CGSizeMake(width, 0);
	NSString *text = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]] componentsJoinedByString:@""];
	NSDictionary *attributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:COLORTEXT};
	NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;
	CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:options attributes:attributes context:NULL];
	CGSize size = CGSizeMake(rect.size.width, rect.size.height);
	return size;
}

//全小写
- (NSString*)strtolower{
	return [self lowercaseString];
}

//全大写
- (NSString*)strtoupper{
	return [self uppercaseString];
}

//各单词首字母大写
- (NSString*)strtoupperFirst{
	return [self capitalizedString];
}

//清除首尾空格和换行
- (NSString*)trim{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//清除首尾指定字符串
- (NSString*)trim:(NSString*)assign{
	return [self preg_replace:[NSString stringWithFormat:@"^(%@)*|(%@)*$", assign, assign] to:@""];
}

//清除换行
- (NSString*)trimNewline{
	NSString *str = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return str;
}

//一个字符串搜索另一个字符串
- (NSInteger)indexOf:(NSString*)str{
	if (!self.length || !str.length) return NSNotFound;
	NSRange range = [self rangeOfString:str];
	NSInteger location = range.location;
	NSInteger length = range.length;
	if (length>0) {
		return location;
	} else {
		return NSNotFound;
	}
}
- (NSInteger (^)(NSString*))indexOf{
	return ^NSInteger(NSString *str){
		return [self indexOf:str];
	};
}

//替换字符串
- (NSString*)replace:(NSString*)r1 to:(NSString*)r2{
	if (self.length<=0) return @"";
	return [self stringByReplacingOccurrencesOfString:r1 withString:r2];
}

//截取字符串
- (NSString*)substr:(NSInteger)start length:(NSInteger)length{
	if (self.length<start || self.length-start<length) return self;
	return [self substringWithRange:NSMakeRange(start,length)];
}

//截取字符串,从指定位置开始到最后,负数:从字符串结尾的指定位置开始
- (NSString*)substr:(NSInteger)start{
	if (start<0) {
		start = self.length + start;
		if (start<0) start = 0;
	}
	if (self.length<start) return self;
	return [self substringFromIndex:start];
}

//从左边开始截取字符串
- (NSString*)left:(NSInteger)length{
	if (self.length<length) return self;
	return [self substringToIndex:length];
}

//从右边开始截取字符串
- (NSString*)right:(NSInteger)length{
	if (self.length<length) return self;
	NSUInteger len = self.length;
	NSUInteger start = 0;
	if (len>length) start = len - length;
	return [self substringFromIndex:start];
}

//某字符串出现次数
- (NSInteger)countStrings:(NSString*)string{
	NSInteger strCount = self.length - [[self stringByReplacingOccurrencesOfString:string withString:@""] length];
	return strCount / string.length;
}

//获取中英文混编的字符串长度
- (NSInteger)fontLength{
	if (self.length<=0) return 0;
	NSInteger p = 0;
	for (int i=0; i<self.length; i++) {
		NSRange range = NSMakeRange(i, 1);
		NSString *subString = [self substringWithRange:range];
		const char *cString = [subString UTF8String];
		if (strlen(cString) == 3) {
			p += 2;
		} else {
			p++;
		}
	}
	return p;
}

//分割字符串转为数组
- (NSMutableArray*)splitString{
	return [self explode:@""];
}
- (NSMutableArray*)split:(NSString*)symbol{
	return [self explode:symbol];
}
- (NSMutableArray*)explode:(NSString*)symbol{
	if (symbol.length) {
		NSArray *array = [self componentsSeparatedByString:symbol];
		return [NSMutableArray arrayWithArray:array];
	}
	NSMutableArray *array = [[NSMutableArray alloc]init];
	NSString *text = self.copy;
	for (NSInteger i=0; i<text.length; i++) {
		NSString *str = [text substringToIndex:1];
		text = [text substringFromIndex:1];
		i = 0;
		[array addObject:str];
		if (text.length == 1) [array addObject:text];
	}
	return array;
}
- (NSMutableArray *(^)(NSString*))split{
	return ^id(NSString *symbol){
		return [self explode:symbol];
	};
}
- (NSMutableArray *(^)(NSString*))explode{
	return ^id(NSString *symbol){
		return [self explode:symbol];
	};
}

//按指定长度分割字符串,length:规定每个数组元素的长度
- (NSMutableArray*)str_split:(NSInteger)length{
	if (self.length<=length) return [NSMutableArray arrayWithObjects:self, nil];
	NSString *str = [self copy];
	NSMutableArray *res = [[NSMutableArray alloc]init];
	for (int i=0; i<str.length; i+=length) {
		if (str.length >= length) {
			[res addObject:[str substr:0 length:length]];
			str = [str substr:length];
		} else {
			[res addObject:str];
		}
	}
	return res;
}

//将手机号码中间设为星号
- (NSString*)markMobile{
	if (!self.length) return @"";
	NSString *mobile = self;
	if (mobile.isMobile) {
		mobile = [mobile stringByReplacingCharactersInRange:NSMakeRange(3, 5) withString:@"*****"];
	}
	return mobile;
}

//网址参数转字典
- (NSMutableDictionary*)params{
	return [self params:@"?"];
}
- (NSMutableDictionary*)params:(NSString*)mark{
	NSArray *parts = [self split:mark];
	if (parts.count<2) return nil;
	parts = [parts.lastObject split:@"&"];
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	for (int i=0; i<parts.count; i++) {
		NSArray *kv = [parts[i] split:@"="];
		[params setObject:[[kv[1] URLDecode] replace:@"+" to:@" "] forKey:kv[0]];
	}
	return params;
}

//截取所需字符串
//cropHtml(HTML代码, 所需代码前面的特征代码[会被去除], 所需代码末尾的特征代码[会被去除])
//得到代码后请自行使用str_replace所需代码部分中不需要的代码
- (NSString*)cropHtml:(NSString*)startStr overStr:(NSString*)overStr{
	NSString *webHtml = self;
	if(webHtml.length>0){
		if(startStr.length>0 && [webHtml indexOf:startStr]!=NSNotFound){
			NSArray *array = [webHtml split:startStr];
			webHtml = array[1];
		}
		if(overStr.length>0 && [webHtml indexOf:overStr]!=NSNotFound){
			NSArray *array = [webHtml split:overStr];
			webHtml = array[0];
		}
	}
	return webHtml;
}

//删除例如 [xxxx] 组合的字符串段落
- (NSString*)deleteStringPart:(NSString*)prefix suffix:(NSString*)suffix{
	NSString *str = nil;
	NSInteger length = self.length;
	if (length > 0) {
		if ([suffix isEqualToString:[self substringFromIndex:length-suffix.length]]) {
			if ([self rangeOfString:prefix].location == NSNotFound) {
				str = [self substringToIndex:length-prefix.length];
			} else {
				str = [self substringToIndex:[self rangeOfString:prefix options:NSBackwardsSearch].location];
			}
		} else {
			for (int i=1; i<=2; i++) {
				if (length>i) {
					if ([[self substringFromIndex:length-i] isEmoji]) {
						return [self substringToIndex:length-i];
						break;
					}
				}
			}
			str = [self substringToIndex:length-1];
		}
	}
	return str;
}

//正则表达式test
- (BOOL)preg_test:(NSString*)patton{
	if (!self || ![self isKindOfClass:[NSString class]] || !self.length) return NO;
	NSArray *matcher = [self preg_match:patton];
	return matcher.isArray;
	//NSPredicate *match = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", patton];
	//return [match evaluateWithObject:self];
}

//正则表达式replace
- (NSString*)preg_replace:(NSString*)patton to:(NSString*)templateStr{
	if (!self || ![self isKindOfClass:[NSString class]] || !self.length) return self;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
																		   options:NSRegularExpressionCaseInsensitive
																			 error:nil];
	NSString *modified = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:templateStr];
	return modified;
}

//正则表达式replace, 根据replacement返回字符串来替换
- (NSString*)preg_replace:(NSString*)patton replacement:(NSString *(^)(NSDictionary *matcher, NSInteger index))replacement{
	if (!self || ![self isKindOfClass:[NSString class]] || !self.length || !replacement) return self;
	NSString *modified = self;
	NSArray *matches = [self preg_match:patton];
	if (matches.count) {
		for (NSInteger i=0; i<matches.count; i++) {
			NSDictionary *matcher = matches[i];
			NSInteger loc = [modified indexOf:matcher[@"value"]];
			NSInteger len = [matcher[@"value"] length];
			modified = [modified stringByReplacingCharactersInRange:NSMakeRange(loc, len) withString:replacement(matcher, i)];
		}
	}
	return modified;
}

//正则表达式match
- (NSMutableArray*)preg_match:(NSString*)patton{
	NSMutableArray *matcher = [[NSMutableArray alloc]init];
	if (!self || ![self isKindOfClass:[NSString class]] || !self.length) return matcher;
	NSError *error = nil;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patton
																		   options:NSRegularExpressionCaseInsensitive
																			 error:&error];
	if (error) {
		NSLog(@"%@", error);
		return matcher;
	}
	NSArray *matches = [regex matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
	//NSLog(@"%@", matches);
	for (NSTextCheckingResult *match in matches) {
		NSMutableArray *group = [[NSMutableArray alloc]init];
		for (NSInteger i=1; i<=match.numberOfRanges-1; i++) {
			if ([match rangeAtIndex:i].length) {
				[group addObject:[self substringWithRange:[match rangeAtIndex:i]]];
			} else {
				[group addObject:@""];
			}
		}
		NSString *value = [self substringWithRange:match.range];
		[matcher addObject:@{@"group":group, @"value":value}];
	}
	return matcher;
}

//为又拍云图片路径增加后缀,即转换为缩略图路径
- (NSString*)UpyunSuffix:(NSString*)suffix{
	NSString *result = [self preg_replace:@"http:\\/\\/\\w+\\.b0\\.upaiyun\\.com\\/[^\"]+" replacement:^NSString *(NSDictionary *matcher, NSInteger index) {
		if (![matcher[@"value"] preg_test:@"!\\w+$"]) return FORMAT(@"%@%@", matcher[@"value"], suffix);
		return matcher[@"value"];
	}];
	return result;
}
//把又拍云图片指定后缀替换为其他指定后缀
- (NSString*)UpyunSuffixReplace:(NSString*)originSuffix to:(NSString*)suffix{
	NSString *result = [self preg_replace:@"http:\\/\\/\\w+\\.b0\\.upaiyun\\.com\\/[^\"]+" replacement:^NSString *(NSDictionary *matcher, NSInteger index) {
		return [matcher[@"value"] replace:originSuffix to:@""];
	}];
	return [result UpyunSuffix:suffix];
}

//Json字符串转Dictionary、Array
- (id)jsonValue{
	return [self formatJson];
}
- (id)formatJson{
	if (!self || ![self isKindOfClass:[NSString class]] || !self.length) return nil;
	NSString *json = [self trim];
	json = [json replace:@":null" to:@":\"\""];
	//json = [json replace:@":[]" to:@":\"\""];
	//json = [json replace:@":{}" to:@":\"\""];
	@try {
		NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
		id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
		if (![json isKindOfClass:[NSDictionary class]]) {
			NSLog(@"%@", self);
			return nil;
		}
		return json;
	} @catch (NSException *exception) {
		NSLog(@"%@", self);
	}
	return nil;
}

//是否为整型
- (BOOL)isInt{
	return [self isInt:self.length];
}
- (BOOL)isInt:(NSInteger)length{
	if (!self.length) return NO;
	NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
	int val;
	return [scan scanInt:&val] && [scan isAtEnd];
}

//是否为浮点型
- (BOOL)isFloat{
	return [self isFloat:self.length];
}
- (BOOL)isFloat:(NSInteger)length{
	if (!self.length) return NO;
	NSScanner *scan = [NSScanner scannerWithString:[self substringToIndex:length]];
	float val;
	return [scan scanFloat:&val] && [scan isAtEnd];
}

//用户名
- (BOOL)isUsername{
	return [self preg_test:@"^[A-Za-z0-9]{6,20}+$"];
}

//密码
- (BOOL)isPassword{
	return [self preg_test:@"^[a-zA-Z0-9]{6,20}+$"];
}

//是否存在中文字
- (BOOL)hasChinese{
	BOOL has = NO;
	NSInteger length = self.length;
	for (NSInteger i=0; i<length; i++) {
		NSRange range = NSMakeRange(i, 1);
		NSString *subString = [self substringWithRange:range];
		const char *string = [subString UTF8String];
		if (strlen(string) == 3) {
			has = YES;
			break;
		}
	}
	return has;
}

//全中文
- (BOOL)isChinese{
	return [self preg_test:@"^[\u4e00-\u9fa5]+$"];
}

//邮箱
- (BOOL)isEmail{
	return [self preg_test:@"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$"];
}

//手机号码
- (BOOL)isMobile{
	return [self preg_test:@"^1[3-8]+\\d{9}$"];
	//^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$
}

//日期
- (BOOL)isDate{
	return [self preg_test:@"^\\d{4}-\\d{1,2}-\\d{1,2}( \\d{1,2}:\\d{1,2}:\\d{1,2})?$"];
}

//网址
- (BOOL)isUrl{
	return [self preg_test:@"^(http|https|ftp):(\\/\\/|\\\\)(([\\w\\/\\\\+\\-~`@:%])+\\.)+([\\w\\/\\\\.=\\?\\+\\-~`@\\':!%#]|(&amp;)|&)+"];
}

//身份证
- (BOOL)isIDCard{
	NSInteger length = self.length;
	if (length!=15 && length!=18) return NO;
	NSArray *codeArray = @[@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2"];
	NSDictionary *checkCodeDic = [NSDictionary dictionaryWithObjects:@[@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2"]
															 forKeys:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]];
	int sumValue = 0;
	if (length==18) {
		if (![self isInt:17]) return NO;
		for (int i=0; i<17; i++) {
			sumValue += [[self substringWithRange:NSMakeRange(i, 1)]intValue] * [[codeArray objectAtIndex:i]intValue];
		}
		NSString *strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d", sumValue%11]];
		if ([strlast isEqualToString:[[self substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) return YES;
	} else {
		if (![self isInt:15]) return NO;
		NSRegularExpression *regularExpression;
		int year = [self substringWithRange:NSMakeRange(6,2)].intValue + 1900;
		if (year%4==0 || (year%100==0 && year%4==0)) {
			regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
																	options:NSRegularExpressionCaseInsensitive
																	  error:nil];
		} else {
			regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
																	options:NSRegularExpressionCaseInsensitive
																	  error:nil];
		}
		sumValue = (int)[regularExpression numberOfMatchesInString:self
														   options:NSMatchingReportProgress
															 range:NSMakeRange(0, length)];
		if (sumValue > 0) return YES;
	}
	return NO;
}

//字符串公式计算
- (double)calculateFormula{
	if (!self || !self.length) return 0;
	return [[self calcComplexFormulaString:self] doubleValue];
}
//字符串加
- (NSString *)addV1:(NSString *)v1 v2:(NSString *)v2{
	CGFloat result = [v1 floatValue] + [v2 floatValue];
	return [NSString stringWithFormat:@"%.2f", result];
}
//字符串减
- (NSString *)subV1:(NSString *)v1 v2:(NSString *)v2{
	CGFloat result = [v1 floatValue] - [v2 floatValue];
	return [NSString stringWithFormat:@"%.2f", result];
}
//字符串乘
- (NSString *)mulV1:(NSString *)v1 v2:(NSString *)v2{
	CGFloat result = [v1 floatValue] * [v2 floatValue];
	return [NSString stringWithFormat:@"%.2f", result];
}
//字符串除
- (NSString *)divV1:(NSString *)v1 v2:(NSString *)v2{
	CGFloat result = [v1 floatValue] / [v2 floatValue];
	return [NSString stringWithFormat:@"%.2f", result];
}
//字符串sin
- (NSString *)sinV1:(NSString *)v1{
	double result =sin([v1 floatValue]*M_PI/180.0);
	return [NSString stringWithFormat:@"%.4f", result];
}
//字符串cos
- (NSString *)cosV1:(NSString *)v1{
	double result =cos([v1 floatValue]*M_PI/180.0);
	return [NSString stringWithFormat:@"%.4f", result];
}
//字符串tan
- (NSString *)tanV1:(NSString *)v1{
	double result =tan([v1 floatValue]*M_PI/180.0);
	return [NSString stringWithFormat:@"%.4f", result];
}
//简单只包含 + - 的计算
- (NSString *)calcSimpleFormula:(NSString *)formula{
	NSString *result = @"0";
	char symbol = '+';
	int len = (int)formula.length;
	int numStartPoint = 0;
	for (int i = 0; i < len; i++) {
		char c = [formula characterAtIndex:i];
		if (c == '+' || c == '-') {
			NSString *num = [formula substringWithRange:NSMakeRange(numStartPoint, i - numStartPoint)];
			switch (symbol) {
				case '+':
					result = [self addV1:result v2:num];
					break;
				case '-':
					result = [self subV1:result v2:num];
					break;
				default:
					break;
			}
			symbol = c;
			numStartPoint = i + 1;
		}
	}
	if (numStartPoint < len) {
		NSString *num = [formula substringWithRange:NSMakeRange(numStartPoint, len - numStartPoint)];
		switch (symbol) {
			case '+':
				result = [self addV1:result v2:num];
				break;
			case '-':
				result = [self subV1:result v2:num];
				break;
			default:
				break;
		}
	}
	return result;
}
//获取字符串中的前置数字
- (NSString *)firstNumberWithString:(NSString *)str{
	int numEndPoint = (int)str.length;
	for (int i = 0; i < str.length; i++) {
		char c = [str characterAtIndex:i];
		if ((c < '0' || c > '9') && c != '.') {
			numEndPoint = i;
			break;
		}
	}
	return [str substringToIndex:numEndPoint];
}
//获取字符串中的后置数字
- (NSString *)lastNumberWithString:(NSString *)str{
	int numStartPoint = 0;
	for (int i =(int)str.length-1; i >= 0; i--) {
		char c = [str characterAtIndex:i];
		if ((c < '0' || c > '9') && c != '.') {
			numStartPoint = i + 1;
			break;
		}
	}
	return [str substringFromIndex:numStartPoint];
}
//包含 * / 的计算
- (NSString *)calcNormalFormula:(NSString *)formula{
	NSRange mulRange = [formula rangeOfString:@"*" options:NSLiteralSearch];
	NSRange divRange = [formula rangeOfString:@"/" options:NSLiteralSearch];
	//只包含加减的运算
	if (mulRange.length == 0 && divRange.length == 0) {
		return [self calcSimpleFormula:formula];
	}
	//进行乘除运算
	int index = (int)mulRange.length > 0 ? (int) mulRange.location : (int)divRange.location;
	//计算左边表达式
	NSString *left = [formula substringWithRange:NSMakeRange(0, index)];
	NSString *num1 = [self lastNumberWithString:left];
	left = [left substringWithRange:NSMakeRange(0, left.length - num1.length)];
	//计算右边表达式
	NSString *right = [formula substringFromIndex:index + 1];
	NSString *num2 = [self firstNumberWithString:right];
	right = [right substringFromIndex:num2.length];
	//计算一次乘除结果
	NSString *tempResult = @"0";
	if (index == mulRange.location) {
		tempResult = [self mulV1:num1 v2:num2];
	} else if(index == divRange.location) {
		tempResult = [self divV1:num1 v2:num2];
	}
	//代入计算得到新的公式
	NSString *newFormula = [NSString stringWithFormat:@"%@%@%@", left, tempResult, right];
	return [self calcNormalFormula:newFormula];
}
//三角函数计算公式计算,接口主方法
- (NSString *)calcSanJiaoFormulaString:(NSString *)formula{
	NSRange sinRange = [formula rangeOfString:@"sin" options:NSLiteralSearch];
	NSRange cosRange = [formula rangeOfString:@"cos" options:NSLiteralSearch];
	NSRange tanRange = [formula rangeOfString:@"tan" options:NSLiteralSearch];
	if (sinRange.length==0&&cosRange.length==0&&tanRange.length==0) {
		return [self calcNormalFormula:formula];
	} else if (sinRange.length==3) {
		//获取sin左边的表达式
		NSString *left1 = [formula substringWithRange:NSMakeRange(0, sinRange.location)];
		//获取sin括号右边的表达式
		NSString *right1 = [formula substringFromIndex:sinRange.location+3];
		NSString *right2 =[formula substringFromIndex:sinRange.location+8];
		NSString *tempResult;
		tempResult = [self sinV1:right1];
		formula = [NSString stringWithFormat:@"%@%@%@", left1, [self calcNormalFormula:tempResult],right2];
	} else if (cosRange.length==3) {
		//获取sin左边的表达式
		NSString *left1 = [formula substringWithRange:NSMakeRange(0, cosRange.location)];
		//获取sin括号右边的表达式
		NSString *right1 = [formula substringFromIndex:cosRange.location+3];
		NSString *right2 =[formula substringFromIndex:cosRange.location+8];
		NSString *tempResult;
		tempResult = [self cosV1:right1];
		formula = [NSString stringWithFormat:@"%@%@%@", left1, [self calcNormalFormula:tempResult],right2];
	} else if (tanRange.length==3) {
		//获取sin左边的表达式
		NSString *left1 = [formula substringWithRange:NSMakeRange(0, tanRange.location)];
		//获取sin括号右边的表达式
		NSString *right1 = [formula substringFromIndex:tanRange.location+3];
		NSString *right2 =[formula substringFromIndex:tanRange.location+8];
		NSString *tempResult;
		tempResult = [self tanV1:right1];
		formula = [NSString stringWithFormat:@"%@%@%@", left1, [self calcNormalFormula:tempResult],right2];
	}
	return [self calcSanJiaoFormulaString:formula];
}
//复杂计算公式计算,接口主方法
- (NSString *)calcComplexFormulaString:(NSString *)formula{
	//左括号
	NSRange lRange = [formula rangeOfString:@"(" options:NSBackwardsSearch];
	if (lRange.length == 0) {
		return [self calcSanJiaoFormulaString:formula];
	}
	//右括号
	NSRange rRange = [formula rangeOfString:@")" options:NSLiteralSearch range:NSMakeRange(lRange.location, formula.length-lRange.location)];
	//获取括号左右边的表达式
	NSString *left = [formula substringWithRange:NSMakeRange(0, lRange.location)];
	NSString *right = [formula substringFromIndex:rRange.location + 1];
	//括号内的表达式
	NSString *middle = [formula substringWithRange:NSMakeRange(lRange.location+1, rRange.location-lRange.location-1)];
	//代入计算新的公式
	NSString *newFormula = [NSString stringWithFormat:@"%@%@%@", left, [self calcNormalFormula:middle], right];
	return [self calcComplexFormulaString:newFormula];
}

//是否Emoji表情
- (BOOL)isEmoji{
	__block BOOL returnValue = NO;
	[self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		const unichar hs = [substring characterAtIndex:0];
		if (0xd800 <= hs && hs <= 0xdbff) {
			if (substring.length > 1) {
				const unichar ls = [substring characterAtIndex:1];
				const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
				if (0x1d000 <= uc && uc <= 0x1f77f) {
					returnValue = YES;
				}
			}
		} else if (substring.length > 1) {
			const unichar ls = [substring characterAtIndex:1];
			if (ls == 0x20e3) {
				returnValue = YES;
			}
		} else {
			if (0x2100 <= hs && hs <= 0x27ff) {
				returnValue = YES;
			} else if (0x2B05 <= hs && hs <= 0x2b07) {
				returnValue = YES;
			} else if (0x2934 <= hs && hs <= 0x2935) {
				returnValue = YES;
			} else if (0x3297 <= hs && hs <= 0x3299) {
				returnValue = YES;
			} else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
				returnValue = YES;
			}
		}
	}];
	return returnValue;
}

//获取完整文件名(带后缀名)(支持网址)
- (NSString*)getFullFilename{
	return [self lastPathComponent];
}

//获取文件名(不带后缀名)
- (NSString*)getFilename{
	return [self stringByDeletingPathExtension];
}

//获取后缀名
- (NSString*)getSuffix{
	return [self pathExtension];
}

//转换字符串(兼容emoji)
- (NSString*)encode{
	NSData *data = [self dataUsingEncoding:NSNonLossyASCIIStringEncoding];
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
//还原字符串(兼容emoji)
- (NSString*)decode{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
}

- (NSString*)ASCII{
	NSString *str = [NSString stringWithCString:[self cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
	return str;
}

- (NSString*)Unicode{
	NSString *str = [NSString stringWithCString:[self cStringUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding];
	return str;
}

//URL编码
- (NSString*)URLEncode{
	return [self URLEncode:NSUTF8StringEncoding];
}

//URL编码,可设置字符编码
- (NSString*)URLEncode:(NSStringEncoding)encoding{
	if (!self.length) return @"";
	NSArray *escapeChars = @[@";", @"/", @"?", @":", @"@", @"&", @"=", @"+", @"$", @",", @"!", @"'", @"(", @")", @"*"];
	NSArray *replaceChars = @[@"%3B", @"%2F", @"%3F", @"%3A", @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21", @"%27", @"%28", @"%29", @"%2A"];
	NSInteger len = [escapeChars count];
	NSMutableString *temp = [[self stringByAddingPercentEscapesUsingEncoding:encoding] mutableCopy];
	int i;
	for (i=0; i<len; i++) {
		[temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
	}
	NSString *outStr = [NSString stringWithString:temp];
	return outStr;
}

//URL编码,空格转为加号
- (NSString*)URLEncodeSpace{
	NSString *outStr = [self URLEncode:NSUTF8StringEncoding];
	outStr = [outStr stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
	return outStr;
}

//URL解码
- (NSString*)URLDecode{
	return [self URLDecode:NSUTF8StringEncoding];
}

//URL解码,可设置字符编码
- (NSString*)URLDecode:(NSStringEncoding)encoding{
	return [self stringByReplacingPercentEscapesUsingEncoding:encoding];
}

//转Base64
- (NSString*)base64{
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return data.base64;
}
- (NSString*)base64Encode{
	return [self base64];
}

//Base64转NSString
- (NSString*)base64Decode{
	return [self base64ToString];
}
- (NSString*)base64ToString{
	NSData *data = self.base64ToData;
	return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

//Base64转NSData
- (NSData*)base64ToData{
	return [[NSData alloc]initWithBase64EncodedString:self options:0];
}

//Base64转UIImage
- (UIImage*)base64ToImage{
	NSURL *url = [NSURL URLWithString:self];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *image = [UIImage imageWithData:data];
	return image;
}

//转MD5, 16位:CC_MD5_DIGEST_LENGTH, 64位:CC_MD5_BLOCK_BYTES
- (NSString*)md5{
	if (!self.length) return @"";
	const char *cStr = [self UTF8String];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
	for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", digest[i]];
	return output;
}

//转SHA1, 20位:CC_SHA1_DIGEST_LENGTH, 64位:CC_SHA1_BLOCK_BYTES
- (NSString*)sha1{
	if (!self.length) return @"";
	NSInteger length = CC_SHA1_BLOCK_BYTES;
	const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:self.length];
	uint8_t digest[length];
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	NSMutableString* output = [NSMutableString stringWithCapacity:length * 2];
	for (int i = 0; i < length; i++) [output appendFormat:@"%02x", digest[i]];
	return output;
}

//转化简单HTML代码为iOS文本
- (NSAttributedString*)simpleHtml{
	NSAttributedString *html = [[NSAttributedString alloc] initWithData:[self dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
	return html;
}

//缓存网络图片
- (void)cacheImageAndCompletion:(void (^)(UIImage *image, NSData *imageData))completion{
	[self loadImageAndCompletion:completion];
}
- (void)loadImageAndCompletion:(void (^)(UIImage *image, NSData *imageData))completion{
	[Global cacheImageWithUrl:self completion:completion];
}

//使用标签自定义UILabel字体
/*
 NSString *string = [NSString stringWithFormat:@"<e>￥</e><bp>%.1f</bp>", [dic[@"price"]floatValue]];
 NSDictionary *style = @{@"body":@[FONT(12),COLORRGB(@"c0c0c0")], @"e":FONTBOLD(10), @"bp":FONT(16)};
 price.attributedText = [string attributedStyle:style];
 */
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook{
	return [self attributedStyle:styleBook withLabel:nil linkAction:nil];
}
- (NSAttributedString*)attributedStyle:(NSDictionary*)styleBook withLabel:(UILabel *)label linkAction:(void (^) (NSString *string, NSRange range, NSInteger index, NSString *href))linkAction{
	NSMutableArray *tags = [[NSMutableArray alloc]init];
	NSMutableString *ms = [self mutableCopy];
	[ms replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceOccurrencesOfString:@"<br/>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceOccurrencesOfString:@"<br >" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceOccurrencesOfString:@"<br />" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, ms.length)];
	[ms replaceAllTagsIntoArray:tags];
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc]initWithString:ms];
	NSObject *bodyStyle = styleBook[@"body"];
	if (bodyStyle) [self styleAttributedString:as range:NSMakeRange(0, as.length) withStyle:bodyStyle withStyleBook:styleBook];
	for (NSDictionary *tag in tags) {
		if (tag[@"loc"]!=nil && tag[@"endloc"]!=nil) {
			NSString *t = tag[@"tag"];
			NSNumber *loc = tag[@"loc"];
			NSNumber *endloc = tag[@"endloc"];
			NSString *attr = tag[@"attr"];
			NSString *text = tag[@"text"];
			NSRange range = NSMakeRange([loc integerValue], [endloc integerValue] - [loc integerValue]);
			NSObject *style = styleBook[t];
			if (style) {
				//*//
				if ([t isEqualToString:@"b"]) { //字体宽度,正值中空,负值填充
					[as removeAttribute:NSStrokeWidthAttributeName range:range];
					[as addAttribute:NSStrokeWidthAttributeName value:style range:range];
				} else if ([t isEqualToString:@"u"]) { //下划线,值越大线条越粗
					[as removeAttribute:NSUnderlineStyleAttributeName range:range];
					[as addAttribute:NSUnderlineStyleAttributeName value:style range:range];
				} else if ([t isEqualToString:@"i"]) { //字形倾斜度,正值右倾,负值左倾
					[as removeAttribute:NSObliquenessAttributeName range:range];
					[as addAttribute:NSObliquenessAttributeName value:style range:range];
				} else if ([t isEqualToString:@"s"]) { //中划线,值越大线条越粗
					[as removeAttribute:NSStrikethroughStyleAttributeName range:range];
					[as addAttribute:NSStrikethroughStyleAttributeName value:style range:range];
				} else if ([t isEqualToString:@"line-height"]) { //行高,值越大相隔越大
					NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
					[paragraphStyle setLineSpacing:[(NSNumber*)style floatValue]];
					//[as removeAttribute:NSParagraphStyleAttributeName range:range];
					[as addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
				} else if ([t isEqualToString:@"align"]) { //行高,值越大相隔越大
					NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
					if ([(NSString*)style isEqualToString:@"center"]) {
						paragraphStyle.alignment = NSTextAlignmentCenter;
					} else if ([(NSString*)style isEqualToString:@"left"]) {
						paragraphStyle.alignment = NSTextAlignmentLeft;
					} else if ([(NSString*)style isEqualToString:@"right"]) {
						paragraphStyle.alignment = NSTextAlignmentRight;
					}
					//[as removeAttribute:NSParagraphStyleAttributeName range:range];
					[as addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
				} else if ([t isEqualToString:@"margin-bottom"]) { //文字位置偏移,正值上偏,负值下偏
					[as removeAttribute:NSBaselineOffsetAttributeName range:range];
					[as addAttribute:NSBaselineOffsetAttributeName value:style range:range];
				} else if ([t isEqualToString:@"letter-spacing"]) { //字体间隔,值越大间隔越大
					[as removeAttribute:NSKernAttributeName range:range];
					[as addAttribute:NSKernAttributeName value:style range:range];
				} else if ([t isEqualToString:@"style"]) { //字体样式,值为NSMutableParagraphStyle
					[as removeAttribute:NSParagraphStyleAttributeName range:range];
					[as addAttribute:NSParagraphStyleAttributeName value:style range:range];
				} else if ([t isEqualToString:@"a"]) {
					if (attr.length && text.length && label && linkAction) {
						NSArray *matcher = [attr preg_match:@"href=\"([^\"]+)\""];
						NSString *href = matcher[0][@"group"][0];
						if (href.length) {
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_global_queue(0, 0), ^(void){
								dispatch_async(dispatch_get_main_queue(), ^{
									[label clickWithStrings:@[text] action:^(NSString *string, NSRange range, NSInteger index) {
										linkAction(string, range, index, href);
									}];
								});
							});
						}
					}
				}
				//*/
				//自定义标签
				[self styleAttributedString:as range:range withStyle:style withStyleBook:styleBook];
			}
		}
	}
	return as;
}
- (void)styleAttributedString:(NSMutableAttributedString*)as range:(NSRange)range withStyle:(NSObject*)style withStyleBook:(NSDictionary*)styleBook{
	if ([style isKindOfClass:[NSArray class]]) {
		for (NSObject *subStyle in (NSArray*)style) {
			[self styleAttributedString:as range:range withStyle:subStyle withStyleBook:styleBook];
		}
	} else if ([style isKindOfClass:[NSString class]]) {
		[self styleAttributedString:as range:range withStyle:styleBook[(NSString*)style] withStyleBook:styleBook];
	} else if ([style isKindOfClass:[NSDictionary class]]) {
		[as setAttributes:(NSDictionary*)style range:range];
	} else if ([style isKindOfClass:[UIFont class]]) {
		UIFont *font = (UIFont*)style;
		CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
		if (aFont) {
			[as removeAttribute:(__bridge NSString*)kCTFontAttributeName range:range];
			[as addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)aFont range:range];
			CFRelease(aFont);
		}
	} else if ([style isKindOfClass:[UIColor class]]) {
		[as removeAttribute:NSForegroundColorAttributeName range:range];
		[as addAttribute:NSForegroundColorAttributeName value:(UIColor*)style range:range];
	} else if ([style isKindOfClass:[NSURL class]]) {
		[as removeAttribute:NSLinkAttributeName range:range];
		[as addAttribute:NSLinkAttributeName value:(NSURL*)style range:range];
	} else if ([style isKindOfClass:[UIImage class]]) {
		UIImage *image = (UIImage*)style;
		NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
		attachment.image = image;
		//CGSize s = [self sizeWithAttributes:@{NSFontAttributeName:_textFont}];
		//attachment.bounds = CGRectMake(0, (s.height-image.size.height)/2-(_textFont.lineHeight*0.1), image.size.width, image.size.height);
		[as replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
	}
}

//图文混排
- (NSMutableAttributedString *)exchangeString:(NSString *)string imageName:(NSString *)imageName imageSize:(CGSize)imageSize{
	//1、创建一个可变的属性字符串
	NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
	//2、匹配字符串
	NSError *error = nil;
	NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:&error];
	if (!re) {
		NSLog(@"%@", [error localizedDescription]);
		return attributeString;
	}
	NSArray *resultArray = [re matchesInString:self options:0 range:NSMakeRange(0, self.length)];
	//3、获取所有的图片以及位置
	//用来存放字典，字典中存储的是图片和图片对应的位置
	NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
	//根据匹配范围来用图片进行相应的替换
	for (NSTextCheckingResult *match in resultArray) {
		//获取数组元素中得到range
		NSRange range = [match range];
		//新建文字附件来存放我们的图片(iOS7才新加的对象)
		NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
		//给附件添加图片
		textAttachment.image = [UIImage imageNamed:imageName];
		//修改一下图片的位置,y为负值，表示向下移动
		//textAttachment.bounds = CGRectMake(0, -2, textAttachment.image.size.width, textAttachment.image.size.height);
		textAttachment.bounds = CGRectMake(0, -2, imageSize.width, imageSize.height);
		//把附件转换成可变字符串，用于替换掉源字符串中的表情文字
		NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
		//把图片和图片对应的位置存入字典中
		NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
		[imageDic setObject:imageStr forKey:@"image"];
		[imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
		//把字典存入数组中
		[imageArray addObject:imageDic];
	}
	//4、从后往前替换，否则会引起位置问题
	for (NSInteger i = imageArray.count -1; i >= 0; i--) {
		NSRange range;
		[imageArray[i][@"range"] getValue:&range];
		//进行替换
		[attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
	}
	return attributeString;
}

/*
 *获取汉字拼音的首字母, 返回的字母是大写形式, 例如: @"俺妹", 返回 @"A".
 *如果字符串开头不是汉字, 而是字母, 则直接返回该字母, 例如: @"b彩票", 返回 @"B".
 *如果字符串开头不是汉字和字母, 则直接返回 @"#", 例如: @"&哈哈", 返回 @"#".
 *字符串开头有特殊字符(空格,换行)不影响判定, 例如@"       a啦啦啦", 返回 @"A".
 */
- (NSString *)getFirstLetter{
	NSString *words = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (words.length == 0) return nil;
	NSString *result = nil;
	unichar firstLetter = [words characterAtIndex:0];
	int index = firstLetter - HANZI_START;
	if (index >= 0 && index <= HANZI_COUNT) {
		result = [NSString stringWithFormat:@"%c", firstLetterArray[index]];
	} else if ((firstLetter >= 'a' && firstLetter <= 'z') || (firstLetter >= 'A' && firstLetter <= 'Z')) {
		result = [NSString stringWithFormat:@"%c", firstLetter];
	} else {
		result = @"#";
	}
	return [result uppercaseString];
}

@end

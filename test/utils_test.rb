require "test_helper"

class UtilsTest < Minitest::Test
  def setup
    @utils = IOTA::Utils::Utils.new
  end

  def test_add_checksum
    addressWithoutChecksum = "UYEEERFQYTPFAHIPXDQAQYWYMSMCLMGBTYAXLWFRFFWPYFOICOVLK9A9VYNCKK9TQUNBTARCEQXJHD9VY"
    addressWithChecksum = "UYEEERFQYTPFAHIPXDQAQYWYMSMCLMGBTYAXLWFRFFWPYFOICOVLK9A9VYNCKK9TQUNBTARCEQXJHD9VYXOEDEOMRC"
    assert_equal @utils.addChecksum(addressWithoutChecksum), addressWithChecksum
  end

  def test_checksum_validation
    addressWithChecksum = "UYEEERFQYTPFAHIPXDQAQYWYMSMCLMGBTYAXLWFRFFWPYFOICOVLK9A9VYNCKK9TQUNBTARCEQXJHD9VYXOEDEOMRC"
    assert_equal @utils.isValidChecksum(addressWithChecksum), true
  end

  def test_unit_conversion
    tests = [
      {
        value: 100,
        fromUnit: 'Gi',
        toUnit: 'i',
        expected: 100000000000
      },
      {
        value: 10.1,
        fromUnit: 'Gi',
        toUnit: 'i',
        expected: 10100000000
      },
      {
        value: '10.1000',
        fromUnit: 'Gi',
        toUnit: 'i',
        expected: 10100000000
      },
      {
        value: 1,
        fromUnit: 'i',
        toUnit: 'Ti',
        expected: 0.000000000001
      },
      {
        value: 1,
        fromUnit: 'Ti',
        toUnit: 'i',
        expected: 1000000000000
      },
      {
        value: 1000,
        fromUnit: 'Gi',
        toUnit: 'Ti',
        expected: 1
      },
      {
        value: 133.999111111,
        fromUnit: 'Gi',
        toUnit: 'i',
        expected: 133999111111
      }
    ]

    tests.each do |test|
      converted = @utils.convertUnits(test[:value], test[:fromUnit], test[:toUnit])
      assert_equal test[:expected], converted
    end
  end

  def test_bundle_validation
    tests = [
      # Valid Bundle
      {
        "bundle" => [
          {
            "hash" => "CKUBZGZUZJPZSPHWLPXMJPMWTTQYGSNDMBLSPIVZGHVJHEBABBAXWYKTGYHZAUKAPGALKEBXHHSD99999",
            "signatureMessageFragment" => "999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999",
            "address" => "PPJFBGPEFOMNBNTTCFBTQCGY9BVXTS9LWQVFNXODIHVEPJLFRSJYMYBDFOOFWPIBAYBLBZO9PHYOLEJBA",
            "value" => 1,
            "obsoleteTag" => "BIGTEST99999999999999999999",
            "timestamp" => 1502215514,
            "currentIndex" => 0,
            "lastIndex" => 3,
            "bundle" => "ZNSJHWENEAN9VKGQICUBWGKBKRQVPMDIIUEFNVBYRROMEJNCCHGPJIWQERZASRQDYZKDJDXZJRFRVKRWY",
            "trunkTransaction" => "UEBOMWXEKEQCZFOTGRDF9MXZQDXX9VBKQNKLQDTNMNSY9RM9ZVPHVNXOIYEJLBIPE9JSHMWQPPXZ99999",
            "branchTransaction" => "GPWZXISZREDVZTRCPSZAJYPDHNFF9AGZXIYWIDLVWZDHBIQRPSJPXAUNRMXCZLIRSBHBILATOQYQX9999",
            "tag" => "VUTFNPTRCHCH9JDRPPEJHJDZKJX",
            "attachmentTimestamp" => -1789972691417,
            "attachmentTimestampLowerBound" => -442481168685,
            "attachmentTimestampUpperBound" => -1558788566106,
            "nonce" => "RJTBFCUPVBRCZNAVV9HPS9IRKVM"
          },
          {
            "hash" => "UEBOMWXEKEQCZFOTGRDF9MXZQDXX9VBKQNKLQDTNMNSY9RM9ZVPHVNXOIYEJLBIPE9JSHMWQPPXZ99999",
            "signatureMessageFragment" => "QHYTTDPBSHHHFXNQWXWMOINNIOUXCMJTZGWSCJEMWFUVDSYSRHABDKLPXFGHX9DVOPGCE9CNDPQEYOLRWADEPEQVIAXHVGALDOPHJGSQYFPOCEOZQRVIVNXES9DPCGBYIDIUZRGI9PGZWYHOXNCMDXT9YRXWVBPPABP9XQFS9SNUFIDS9ZDDONYHYGNNEMAAM9XOGYPFIGVXAVEQMTXXLJZFOCILIWUYODUYERZLVFSCRO9PAFWCIGSUQQOAZQOYJZIOMTVCVFLXTCNLIUMVM9FREBSBLEFGWRFGNV9XPOJYVXMXROYDUUWHRSVIOMFHSEVZDNERZMZPVHSYUVCQLKZGDTQNOHSBORQJBLDLDM9OBVJXMMPRTQADQCMPOETPZSGXGYUA9QOWJDBTWXEXBCPLPKVATHQQWTUNDCHCAKOOFWPCOFCRCUMFGWTTSRVNPIQJMOGQJV9UGBVWDQLCGGDJUC9QII9SOYDOGXC9VIPZKOAYL9BSTIUXUPESUMBWYZHXLEAAGCVYHNSUUUGDVILVSUTQBIFSPVQHWGNCQVOV9UQMHAWXBEZFEGHRB9RARBVRHQN9VXVJSCMEQMAFSYXLRZLSPHJUPTJXRQ9AHJWQDBBMKVEPRUIDQJGUVHVMDXNTDUCYTBYGZHZVQFEBGYZGSUPN9GHXLDQGH9RMVSYQ9VTHQXOXRDISURXPYTMLAUKQDCOLXTPRNFYNTZHDYH9UWLTNP9AZMSNV9EIDNUGPQUADTBHO9EKMUHEZKHVZJYZXMUMCONPD9KXXZDWBH9YLZNFVKI9BUWKGAMEUKD9AGGXZGAFWDLJF9XADITKONBUTGUHYYWYKKSCGSFUNGIG9EJIPUETMBDUNGZUPXKEYTQCVKIEIQTURL9XEVPT9RBFHXMCFYDGPRTFUWZWMYRMQVKNYAHKRZIBDN9DWQ9CDUSQBFTDSOTQKCZORVSMIHPJBJ9HWHFG9IUZVOYTQWBMRG9VBSQVTIDBREOXNRARNPAYPLLQGJRWRNJLFE99MEXVOKGEH99VFBAVCJOYTVDMSTRDWBDIEWVWLNZEJCNHIRUKZEPWVFGGITVQLMTDYHSSCHUYPCRDWRRATKHMUWFLRMODOTIYBDVVFPJMHUMFXKDTBGYIRYIHAPFHHOCURRJVTIOSLUMVYCTQKLTZVDJIETCETCQXJITTGMTMXNDGIHAMAPVDEPXRXXMBO9ZWOUJJWHWUFRHLAKGCLIQCPWDJIVZILIWUSNDYPSOEGRAEJGNQBDYWCXZCSNQ9AZFLZ9GDCBJTHXBD9IQLXDUZ9ICEVSOLSTIEQUJNYH9OOZJIVHTDZMIBZ9SVBBBGTEGTCKKUEQZOMDEXXRFLKTDXKGHVXMDOSQGJXDWYRZ9PNSEAZNSZFAJQAAACNHZDMBIBKHAIC9HXELOEGCYN9LVZCDJ9XRDJSNFMBGVZAQZLCCSDUPRRYFCQRBRYMFYEAM9SZWC9JBLQEQJZCWFLZKUKQJTOGRMRCRGKMPYRAIBSQARAZXETXDSRLIGQIBMPQCQAIFVZKJVTHBFT9PRBTHVGCGXFPRBDWLBDRHVJISDNRQEUUIUXMNVHRIUSMIQAMIQHEMF9OBWPUZWHIUEFAMBHZHDGKMKFL9SKTURRPJOKYM9CJYOYTGPRDPOUUZQUTYDBPUDLOPRAVWUWZRRNZGCLVNUATOYALLKQRWDCEDSJKKJWOQFIAMA9XLJYEYWOOUUWGQIOSEAJLOPCXWBEPYURZZRZOYTZVGRCWMOQZGAUGGWFNZHIHHUCAKZPLEQFWBVKLFYIXIJSEQLEFWRUSJFKVIBGHNESKHBYXNUSTUNSSBUJNCETWZ9MZXNHQQWCIDEJFDYBXWTXTWSOUDTUIITZR9OMZNZXDAIOCPSPRAUQRZDBWNFT9OXAOINSXXJSLVSHAHDGHLJAJIDEHNOFJXNTJZ9XAEHTNWKMDFEYCWZ9VYERIXNIMELVOYVGTIB99ACZUJYUMP9MQKPOFIRFMMWQ9YSWHLYLZ9QANFECFLKWBXYEOBH9MYACFUSLVCCWCIJDGJPWZBNGJUKYYIFIESAUAMW9Q9GDKGCMOSFANYUTZTUXEEQJWQCFNMGTLPZDZNRVGPXPSFOFNGKZGNNPQWWEIFOGLHOEUSAOIMKI9JFFBGLQQMWQJPJNOQFSMCJTRIRTVLEQIIIVVICD",
            "address" => "ZWXPIOIUFRIC9EZCUUJWEOZKBWH9ROHCIP9WRZGUXQZMUTMTGGEBPHBUMWK9GTLEXCIVWWR9ZAENHKSJ9",
            "value" => -2000000000,
            "obsoleteTag" => "BIGTEST99999999999999999999",
            "timestamp" => 1502215514,
            "currentIndex" => 1,
            "lastIndex" => 3,
            "bundle" => "ZNSJHWENEAN9VKGQICUBWGKBKRQVPMDIIUEFNVBYRROMEJNCCHGPJIWQERZASRQDYZKDJDXZJRFRVKRWY",
            "trunkTransaction" => "YBRMGZC9SHQNUNDGZEIHETCZJX9DZJ9AAXHGSPQWEAIVC9OSZWVUGBMVX9MUWYJVNNUJTCNOTUGP99999",
            "branchTransaction" => "GPWZXISZREDVZTRCPSZAJYPDHNFF9AGZXIYWIDLVWZDHBIQRPSJPXAUNRMXCZLIRSBHBILATOQYQX9999",
            "tag" => "KOXCGHOATHMIGGHJX9PJYKYCEWI",
            "attachmentTimestamp" => -3519568744220,
            "attachmentTimestampLowerBound" => -2402437163849,
            "attachmentTimestampUpperBound" => 2116140926633,
            "nonce" => "MFSLEXDI9CVT9LE99XOGC9ABHOV"
          },
          {
            "hash" => "YBRMGZC9SHQNUNDGZEIHETCZJX9DZJ9AAXHGSPQWEAIVC9OSZWVUGBMVX9MUWYJVNNUJTCNOTUGP99999",
            "signatureMessageFragment" => "ICJAYWSUQXPRGDBXWGOVLAIHIGTRCLPBZIFMCKWBF9MWICVBGMYYNTSVWDUNALFZMSLMGKTILEUULOBMDCHTKABBHXU9RCNRAGDPEDJLULAXEZYTQQUAXZYARFXUGFDZLRPZSTXLOJFIMBUGHJNLWJNOMULNQOVCBYFNLSZZH9YCEA99UEEGEDXNSISHHMBRSAADCYIP9XICGFSPRLNMXMFVGWHKDUZQLZBKHDVBOAZQBFSYDDYZHQOVYJZAKMFXFIWCMGO9VTYZEAVGEDZFKY9VMTLDWOKSYFUGUF9IWUTZMTHJINKFQ9CNPKUVGXKEJXJZICZSSFHZYDFOKNINWU9IFJUKETQPSUBAKOKFNEWEAYXZEHVDUUATVGRFBDWNTBPETJECHXPUHRGWXOKOYVUJPQKASXBYWDZFGMHAAQGDCQWEAFFGMMANYZ9JGJURTQCLJBGOUQVYVGRWWGHRRGKYSSIDHZZLPVNYPAJYMMHD9EKOYAYVWWVPUHZQTFBOXJQIFVOYXSNQ9XQISMIZAQELLVRVFXQKLKTZSRJNBRPNFFGOTSMDADAYSVVUDPDXYETLZVPH9BSFOJMHVENEIRHKNV9GOEYHZIOSJIMNTUMTBEGFBMZQGXQYADGRE9MPHVXHGFT9YSRAIS9YMMXBYACDQVIXOQLRQSVPGPLHGZUSBTSOEJNEVSEZBYRUDHUJMEDDZRNBUPSDWIDXDKHXHUIE9KSCGYE9PKBTSKRXMCERJWCUENIGJKHKFKXYEXSGFHKYGXCVYETWQERNDIZACUPLXFKBFOLTGYOQIPFX9YPCVIYVNYACOFYSPKHHLKSBXIJQDZLQ9JWPDICSXWTUWHAQIRWHUFHZNYMJMJCVIZWPBGURYIDQSYDTHMBHSB9LFOCGVNNZEXFSQUGFS9IGGNBYDVXQSATZTVKFUYCWQXISDQWFVUJQVQQQBBKGZDZETQKHYQIHDUMYULXVYEX9SKILMGPP9CJPWIWHCFGMCWGOXAGRVFIABEQBSSRFSAAOAYRAQOQWTUIMD9EFTWJZRLHCBRCOWSORAPFRGGSZECFQQDFKWYRSDPLLXJLNZJJMYOG9QZYWEIWY9KWPBPGJZCJZIFDCNFTUGIN9VMJL9XHRJXWNYTBZCYHKTKHWKDGVUDIZJPMXOYUHUVCOULMRRBYH9CJHVGMVLNKZFMYXQFJSYRLILZISXVMTNQ9BLADY9YDBPUOFBQTFJWYUZX99Z9LFJJ9WV9NAMBUEXOZQTNIGPKDEYE9FTO99SSMCCCGWD9DDVAFKRP9OMAGBSHZMORJTIPHOHKT9YEAQCFIULKTYJWUL9ABACZRZUMFZSWFBLOZUUTBSKRLPQCDZNQIWPRXYEZSLWTFRYKWZPHNUXII9MWFCKBEOEXOJC9ITEQNQPQPQUHVQZDJEZNIMRTIEYW99ZIZGVH9QEVCOWZKXAYNCMDWNBWTDAQDMAXCPHTTLUOIXTWLZNRTVSLKQFAQHRJSCMWD9XRFNCXNRUDOILEJPXRAXUCJNMHYBVONKBQYDGMDOPMVJNURTADTGVASPCB9ZPQVWIRI9VVKBTZE99MFGFHFCESXMTXFGLMELWORBZTEMEEZHEEFHRCPY9DMZHPXYI9CPDREJSECKCSIEHUQJACGNPWIOSUCARELRIFHMC9GCRIKK9PVKUCYMILFMRMKCYPVOAIIAVIDNXEXDNMLE9FLUGVFROOJMPRYWXDNWGWTSFNMZPIPWDZOVWLUBQSMJPZUABZJAYN9KLRULXKUXMRLRWYKIE9EYYCODKHCRGZHKOIRSQBP9LAFQAUPPKYNJ9SOMOCPHMRHIYAEKXZMAXZBAQZBDTUBGKQAONOIVBKITECYVELHCST9QHWGALGNBYUNQNALDRZLZIJDPABN9MWDIVTVHHTOHFKFMIYSTOSRXAOYOMCYOLZZSMGWF9KWDMVMMYRPOHHWZKOXYQYAUPWXIPZTXKNZXLUSKZGEMGODFEM9AAOMNH9JDAYIJRA9WBYXGHTZJCUVYQXCXWH9WKLVQBNUYETQPTCRSL9GNARBVQUPEOXSUVNPOCAPWHWJWZNOPGCJLFLIACQZRN9XYNZOU9DZSBTTUUXVAUOVZWDHIZHNWA9KSUWCNU9C9OQXIZYUUQP9QKEOXUIXYTHTRZJIAUKSKFFNVGIPVJGVNVKHDQTTMXKA",
            "address" => "ZWXPIOIUFRIC9EZCUUJWEOZKBWH9ROHCIP9WRZGUXQZMUTMTGGEBPHBUMWK9GTLEXCIVWWR9ZAENHKSJ9",
            "value" => 0,
            "obsoleteTag" => "BIGTEST99999999999999999999",
            "timestamp" => 1502215514,
            "currentIndex" => 2,
            "lastIndex" => 3,
            "bundle" => "ZNSJHWENEAN9VKGQICUBWGKBKRQVPMDIIUEFNVBYRROMEJNCCHGPJIWQERZASRQDYZKDJDXZJRFRVKRWY",
            "trunkTransaction" => "F9AYXWCOWNCRJKTGHRYAURGOCMEXHWQE9YYCLNPOWZECDKPATVVBA9VJJBMEWVPNYYFNYWNDPMUU99999",
            "branchTransaction" => "GPWZXISZREDVZTRCPSZAJYPDHNFF9AGZXIYWIDLVWZDHBIQRPSJPXAUNRMXCZLIRSBHBILATOQYQX9999",
            "tag" => "9GDNXRQSWHOVQWCUXESHIHTSGG9",
            "attachmentTimestamp" => -1576624671529,
            "attachmentTimestampLowerBound" => 116988204706,
            "attachmentTimestampUpperBound" => -2233110606683,
            "nonce" => "KESGKIIXKGV9BPIBCXLBYBBVTCH"
          },
          {
            "hash" => "F9AYXWCOWNCRJKTGHRYAURGOCMEXHWQE9YYCLNPOWZECDKPATVVBA9VJJBMEWVPNYYFNYWNDPMUU99999",
            "signatureMessageFragment" => "999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999",
            "address" => "BRU9LRH9YNGTYMFRODMPMEAPIDTDYUFLQLFWTXKNXQYHSYNEMCFVFGKMIWWOWDFOAJ9RRZVCWX9ELQEP9",
            "value" => 1999999999,
            "obsoleteTag" => "BIGTEST99999999999999999999",
            "timestamp" => 1502215528,
            "currentIndex" => 3,
            "lastIndex" => 3,
            "bundle" => "ZNSJHWENEAN9VKGQICUBWGKBKRQVPMDIIUEFNVBYRROMEJNCCHGPJIWQERZASRQDYZKDJDXZJRFRVKRWY",
            "trunkTransaction" => "GPWZXISZREDVZTRCPSZAJYPDHNFF9AGZXIYWIDLVWZDHBIQRPSJPXAUNRMXCZLIRSBHBILATOQYQX9999",
            "branchTransaction" => "TRKDBAIFTWTNRMCLVGBSXJXZO9VNFMYOSDJXELM9LNUHXOQBFRMNAAZTWURMNGUZDJVXNITXWZKAZ9999",
            "tag" => "MIRMAZTQUR9MMEPCWOMHMDLZPFE",
            "attachmentTimestamp" => -1737679689424,
            "attachmentTimestampLowerBound" => -282646045775,
            "attachmentTimestampUpperBound" => 2918881518838,
            "nonce" => "IJZRLQMGVIYWOS9FDKDRPONJWNB"
          }
        ],
        "expected" => true
      },
      # Invalid Bundle
      {
        "bundle" => [
          {
            "hash" => "IPQYUNLDGKCLJVEJGVVISSQYVDJJWOXCW9RZXIDFKMBXDVZDXFBZNZJKBSTIMBKAXHFTGETEIPTZGNTJK",
            "signatureMessageFragment" => "",
            "address" => "A9RGRKVGWMWMKOLVMDFWJUHNUNYWZTJADGGPZGXNLERLXYWJE9WQHWWBMCPZMVVMJUMWWBLZLNMLDCGDJ",
            "value" => 0,
            "tag" => "999999999999999999999999999",
            "timestamp" => 1482522289,
            "currentIndex" => 0,
            "lastIndex" => 0,
            "bundle" => "TXEFLKNPJRBYZPORHZU9CEMFIFVVQBUSTDGSJCZMBTZCDTTJVUFPTCCVHHORPMGCURKTH9VGJIXUQJVHK",
            "trunkTransaction" => "999999999999999999999999999999999999999999999999999999999999999999999999999999999",
            "branchTransaction" => "999999999999999999999999999999999999999999999999999999999999999999999999999999999",
            "nonce" => "999999999999999999999999999999999999999999999999999999999999999999999999999999999"
          }
        ],
        "expected" => false
      }
    ]

    tests.each_with_index do |test, index|
      bundle = IOTA::Models::Bundle.new(test['bundle'])
      isValid = @utils.isBundle(bundle)
      assert_equal test['expected'], isValid
    end
  end
end

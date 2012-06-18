def stop_words
  words = []

  # http://www.textfixer.com/resources/common-english-words.txt from Wikipedia "Stop words" page
  words += %w(a able about across after all almost also am among an and any are as at be because been but by can cannot could dear did do does either else ever every for from get got had has have he her here hers him his how however i if in into is it its just least let like likely may me might most must my neither no nor not of off often on only or other our own rather said say says she should since so some than that the their them then there these they this tis to too twas us wants was we were what when where which while who whom why will with would yet you your)
  
  # months
  words += %w(jan feb mar apr may jun jul aug sep oct nov dec)
  words += %w(january february march april may june july august september october november december)

  # week
  words += %w(sunday sun monday mon tuesday tue tues wednesday wed thursday thurs thur thu friday fri saturday sat)

  # timezones
  words += %w(ACDT ACST ACT ADT AEDT AEST AFT AKDT AKST AMST AMT ART AST AST AST AST AWDT AWST AZOST AZT BDT BIOT BIT BOT BRT BST BST BTT CAT CCT CDT CEDT CEST CET CHADT CHAST CIST CKT CLST CLT COST COT CST CST CST CT CVT CXT CHST DFT EAST EAT ECT ECT EDT EEDT EEST EET EST FET FJT FKST FKT GALT GET GFT GILT GIT GMT GST GST GYT HADT HAEC HAST HKT HMT HST ICT IDT IRKT IRST IST IST IST JST KRAT KST LHST LINT MAGT MDT MET MEST MIT MSK MST MST MST MUT MYT NDT NFT NPT NST NT NZDT NZST OMST PDT PETT PHOT PKT PST PST RET SAMT SAST SBT SCT SGT SLT SST SST TAHT THA UTC UYST UYT VET VLAT WAT WEDT WEST WET WST YAKT YEKT)

  # ISO county code
  words += %w(ALA AFG ALB DZA ASM AND AGO AIA ATA ATG ARG ARM ABW AUS AUT AZE BHS BHR BGD BRB BLR BEL BLZ BEN BMU BTN BOL BIH BWA BVT BRA IOT BRN BGR BFA BDI KHM CMR CAN CPV CYM CAF TCD CHL CHN CXR CCK COL COM COD COG COK CRI CIV HRV CUB CYP CZE DNK DJI DMA DOM ECU EGY SLV GNQ ERI EST ETH FLK FRO FJI FIN FRA GUF PYF ATF GAB GMB GEO DEU GHA GIB GRC GRL GRD GLP GUM GTM GIN GNB GUY HTI HMD HND HKG HUN ISL IND IDN IRN IRQ IRL ISR ITA JAM JPN JOR KAZ KEN KIR PRK KOR KWT KGZ LAO LVA LBN LSO LBR LBY LIE LTU LUX MAC MKD MDG MWI MYS MDV MLI MLT MHL MTQ MRT MUS MYT MEX FSM MDA MCO MNG MSR MAR MOZ MMR NAM NRU NPL NLD ANT NCL NZL NIC NER NGA NIU NFK MNP NOR OMN PAK PLW PSE PAN PNG PRY PER PHL PCN POL PRT PRI QAT REU ROU RUS RWA SHN KNA LCA SPM VCT WSM SMR STP SAU SEN SCG SYC SLE SGP SVK SVN SLB SOM ZAF SGS ESP LKA SDN SUR SJM SWZ SWE CHE SYR TWN TJK TZA THA TLS TGO TKL TON TTO TUN TUR TKM TCA TUV UGA UKR ARE GBR USA UMI URY UZB VUT VAT VEN VNM VGB VIR WLF ESH YEM ZMB ZWE)

  # internet
  words += %w(ftp http https url URL href HTML html css web form link com net org www)

  # ruby stop words
  #words += %w(rb gem class ensure nil self when def false not super while for or then  and do if redo true line begin else in  undef file break elsif module retry unless encoding case end next return until)
  #words += %w(html css href tag web form id link db url log doc URL HTML)
  #words += open('stopwords1.txt').read.split(/\n/).map{|s| s.strip} rescue []
  #words += open('stopwords2.txt').read.split(/\n/).map{|s| s.strip} rescue []
  #words += open('stopwords3.txt').read.split(/\n/).map{|s| s.strip} rescue []
  words.uniq
end

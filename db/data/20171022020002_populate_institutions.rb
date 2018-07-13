class PopulateInstitutions < ActiveRecord::Migration[4.2]
  INSTITUTIONS = [
    ['ACEG', "Katsuyuki Eguchi, Japan"],
    ['AFRC', "Afribugs Collection Wolmer, Pretoria North, South Africa"],
    ['AMK', "Ant Museum, Thailand"],
    ['AMNH', "American Museum of Natural History. New York, USA"],
    ['AMSA', "Australian Museum. Sydney, Australia"],
    ['ANIC', "Australian National Insect Collection. Canberra, Australia"],
    ['ARCH', "Archbold Biological Station Lake Placid, Florida, U.S.A."],
    ['BBRC', "Barry Bolton Reference Collection Ventnor, Isle of Wight, U.K."],
    ['BMNH', "The Natural History Museum. London, United Kingdom"],
    ['BPBM', "Bernice P. Bishop Museum Honolulu. Hawaii, USA"],
    ['CASC', "California Academy of Sciences. San Francisco, USA"],
    ['CDRS', "Charles Darwin Research Station Galápagos Islands, Ecuador"],
    ['CEC', "Insect Museum at the Centre for Ecological Sciences Bangalore, India"],
    ['CECL', "Coleção Entomológica Angelo Moreira da Costa Lima Seropédica, Rio de Janeiro, Brazil"],
    ['CEPEC', "(also CPDC) Laboratório de Mirmecologia Itabuna, Bahia, Brazil"],
    ['CFRB', "Chinese Academy of Forestry Beijing, China"],
    ['CIUSM', "Colección de Insectos de la Universidad de Santa Marta Santa Marta, Colombia"],
    ['CKC', "Charles Kugler. Radford, VA, USA"],
    ['CNBF', "Centro Nazionale per lo Studio e la Conservazione della Biodiversità Forestale Verona, Italy"],
    ['CPDC', "Centro de Pesquisas do Cacau Ilhéus, Bahia, Brazil"],
    ['CUIC', "Cornell University Insect Collection. Ithaca, NY, USA"],
    ['CWEM', "William and Emma Mackay. USA"],
    ['CZUG', "Centro de Estudios en Zoología de la Universidad de Guadalajara Guadalajara, Jalisco, Mexico"],
    ['CZW', "Herbert and S.V. Zettel Vienna, Austria"],
    ['DBET', "Department of Biodiversity and Evolutionary Taxonomy, University of Wroclaw, Wroclaw, Poland"],
    ['DBUT', "Department of Biology, College of Arts and Sciences, University of Tokyo. Tokyo, Japan"],
    ['DEIC', "Senckenberg Deutsches Entomologisches Institut Müncheberg, Germany"],
    ['DMOC', "David M. Olson Davis, CA, USA"],
    ['DZUP', "Coleção Entomológica Pe. Jesus Santiago Moure Curitiba, Paraná, Brazil"],
    ['EAPZ', "Escuela Agricola Panamericana Tegucigalpa, Honduras"],
    ['EBCC', "Estacion de Biologia Chamela San Patricio, Jalisco, Mexico"],
    ['ECOSCE', "Colección Entomológica de El Colegio de la Frontera Sur San Cristóbal, Chiapas, Mexico"],
    ['ELMES', "Graham W. Elmes, UK"],
    ['ENSA', "Ecole Nationale Superieure Agronomique Toulouse, France"],
    ['FCUR', "Facultad de Ciencias Montevideo, Uruguay"],
    ['FMNH', "Field Museum of Natural History Chicago, U.S.A."],
    ['FRCS', "Forest Research Center Sarawak, Malaysia"],
    ['FRIM', "Forest Research Institute Malaysia. Kepong, Selangor, Malaysia"],
    ['FSCA', "Florida State Collection of Arthropods. Gainsville, USA"],
    ['FSKU', "Entomological Collection of Faculty of Science Kagoshima, Japan"],
    ['GBFM', "Graham B. Fairchild Museo de Invertebrados, Panama"],
    ['HLMD', "Hessisches Landesmuseum Darmstadt Darmstadt, Germany"],
    ['HNHM', "Hungarian Natural History Museum. Budapest, Hungary"],
    ['IAVH', "(also IHVL) Instituto Humboldt. Santa Fe de Bogota, Colombia"],
    ['IHVL', "(also IAVH) Instituto Humboldt. Santa Fe de Bogota, Colombia"],
    ['IBSP', "Instituto Butantan São Paulo, Brazil"],
    ['ICNB', "Museo de Historia Natural Bogotá, Colombia"],
    ['IEBR', "Entomological Collection of the Institute of Ecology and Biological Resources Hanoi, Vietnam"],
    ['IECA', "Czech Academy of Sciences, Institute of Entomology, České Budějovice, Czech Republic"],
    ['IEGG', 'Istituto di Entomologia "Guido Grandi." Bologna, Italy'],
    ['IEXA', "Instituto de Ecología Xalápa, Veracruz, México"],
    ['IMLA', "Fundacion e Instituto Miguel Lillo. Tucuman, Argentina"],
    ['INBC', "Instituto Nacional de Biodiversidad. Heredia, Costa Rica"],
    ['INHS', "Illinois Natural History Survey Insect Collection. Champaign, Illinois, USA"],
    ['INPA', "Instituto Nacional de Pesquisas da Amazonia. Manaus, Brazil"],
    ['ITBC', "Institute for Tropical Biology and Conservation. Kota Kinabalu, Sabah, Malaysia"],
    ['ITLJ', "Laboratory of Insect Systematics. National Institute of Agro-environmental Sciences. Tsukuba, Japa"],
    ['IZAS', "Institute of Zoology, Academia Sinica (Chinese Academy of Sciences). Beijing, China"],
    ['IZAV', "Instituto de Zoologia Agricola. Maracy, Venezuela"],
    ['IZK', "Schmalhausen Institute / Zoological Institute of the Academy of Sciences Ukrainian, Kiev, Ukraine"],
    ['JCTC', "James C. Trager, USA"],
    ['JCUT', "James Cook University. Townsville, Australia"],
    ['JDMC', "Jonathan D. Majer Collection, Curtin University of Technology. Perth, Australia"],
    ['JKWC', "Jim K. Wetterer, USA"],
    ['JTLC', "John T. Longino, USA"],
    ['KGAC', "Kiko Gómez Abal, Barcelona, Spain"],
    ['KSMA', "King Saud Museum of Arthropods, King Saud University, Riyadh, Kingdom of Saudi Arabia"],
    ['KUEC', "Entomological Laboratory and Institute of Tropical Agriculture, Faculty of Agriculture, Kyushu University. Kyushu, Japan"],
    ['KUIC', "Kagoshima University, Faculty of Science Kagoshima, Japan"],
    ['KUM', "Kyushu University, Fukuoka, Japan"],
    ['LACM', "Los Angeles County Museum of Natural History. Los Angeles, USA"],
    ['LPB', "Laboratório de Pesquisas Biológicas Porto Alegre, Brazil"],
    ['LRDC', "Lloyd R. Davis, Jr., USA"],
    ['MACN', "Museo Argentino de Ciencias Naturales Buenos Aires, Argentina"],
    ['MCSN', '(also MSNG) Museo Civico di Storia Naturale "Giacomo Doria." Genoa, Italy'],
    ['MSNG', '(also MCSN) Museo Civico di Storia Naturale "Giacomo Doria." Genoa, Italy'],
    ['MCZC', "Museum of Comparative Zoology. Cambridge, USA"],
    ['MEKOU', "Mike E. Kaspari Collection Oklahoma, U.S.A."],
    ['MEMU', "Mississippi Entomological Museum Mississippi, U.S.A."],
    ['MHNC', "Museo de Historia Natural Bogata, Colombia"],
    ['MHNG', "Musee d'Histoire Naturelle Genève. Geneva, Switzerland"],
    ['MNA', "Museum of Northern Arizona, Flagstaff, Arizona, U.S.A."],
    ['MNHA', "Museum of Nature and Human Activities. Sanda, Hyogo, Japan"],
    ['MNHN', "Musee National d'Histoire Naturelle. Paris, France"],
    ['MNHP', "Museo Nacional de Historia Natural del Paraguay, San Lorenzo, Asuncion, Paraguay"],
    ['MNHW', "Museum of Natural History, University of Wroclaw, Wroclaw, Poland"],
    ['MONZ', "Museum of New Zealand. Wellington, New Zealand"],
    ['MPEG', "Museu Paraense Emilio Goeldi Belém, Pará, Brazil"],
    ['MRAC', "Musee Royal de I' Afrique Centrale. Tervuren, Belgium"],
    ['MSNM', "Museo Civico di Storia Naturale Milano, Italy"],
    ['MSNVR', "Museo Civico di Storia Naturale di Verona Verona, Italy"],
    ['MTD', "(also MTKD) Museum für Tierkunde. Staatliche Naturhistorische Sammlungen Dresden. Dresden, Germany"],
    ['MTKD', "(also MTD) Museum für Tierkunde. Staatliche Naturhistorische Sammlungen Dresden. Dresden, Germany"],
    ['MUSM', "Universidad Nacional Mayor de San Marcos, Museo de Historia Natural. Lima, Peru"],
    ['MVMA', "Museum Victoria. Melbourne, Australia"],
    ['MZB', "Museun Zoologicum Bogoriense Cibinong. Java, Indonesia"],
    ['MZFS', "Museu de Zoologia da Universidade Estadual de Feira de Santana Bahia, Brazil"],
    ['MZL', "Musée de Zoologie Lausanne, Switzerland"],
    ['MZPW', "Museum of the Zoological Institute of the Polish Academy of Sciences Warsaw, Poland"],
    ['MZSP', "Museu de Zoologia da Universidade de Sao Paulo. Sao Paulo, Brazil"],
    ['MZUF', 'Museo Zoologico "La Specola." Firenze, Italy'],
    ['NAIC', "National Agricultural Research Institute, Port Moresby, Papua New Guinea"],
    ['NHMB', "Naturhistorisches Museum. Basel, Switzerland"],
    ['NHMM', "Natuurhistorisch Museum Maastricht, The Netherlands"],
    ['NHMW', "Naturhistorisches Museum Wien. Vienna, Austria"],
    ['NHRS', "Naturhistoriska Riksmuseet. Stockholm, Sweden"],
    ['NIAS', "National Institute of Agro-Environmental Sciences Tsukuba, Japan"],
    ['NMK', "National Museum of Kenya Nairobi, Kenya"],
    ['NMM', "National Museum of the Philippines, Manila, Philippines"],
    ['NSMT', "National Science Museum (Natural History). Tokyo, Japan"],
    ['NTUC', "National Taiwan University. Taipei, Taiwan, China"],
    ['NZAC', "New Zealand Arthropod Collection. Auckland, New Zealand"],
    ['OMNH', "Oklahoma Museum of Natural History. University of Oklahoma. Norman, Oklahoma, USA"],
    ['ONHM', "Oman Natural History Museum Muscat, Oman"],
    ['OUMNH', "Oxford University Museum of Natural History. Oxfordshire, United Kingdom"],
    ['PSWC', "Philip S. Ward Davis, CA, USA"],
    ['PUCE', "Museo de Zoología, Escuela de Biología Quito, Ecuador"],
    ['PUPAC', "Punjabi University Patiala Ant Collection Patiala, India"],
    ['QCAZ', "Museo de Zollogia, Ecuador"],
    ['QMBA', "Queensland Museum. Brisbane, Queensland, Australia"],
    ['RAJC', "Robert A. Johnson Collection Tempe, Arizona, USA"],
    ['RBINS', "Royal Belgian Institute of Natural Sciences Brussels, Belgium"],
    ['RJK', "R.J. Kohout Brisbane, Australia"],
    ['RMCA', "Royal Museum for Central Africa Tervuren, Belgium"],
    ['RMNH', "Leiden Nationaal Natuurhistorische Museum. Leiden, The Netherlands"],
    ['RSC', "Rebecca Strecker Collection, USA"],
    ['SAMA', "South Australian Museum. Adelaide, Australia"],
    ['SAMC', "South African Museum. Cape Town, South Africa"],
    ['SEHU', "Systematic Entomology Collection. Japan"],
    ['SKYC', "SKY Collection. Japan"],
    ['SMNG', "Staatliches Museum für Naturkunde Görlitz. Görlitz, Germany"],
    ['SMNK', "Staatliches Museum fur Naturkunde Karlsruhe. Karlsruhe, Germany"],
    ['SMNS', "Staatliches Museum fur Naturkunde Stuttgart. Stuttgart, Germany"],
    ['SWFU', "Southwest Forestry University. Kunming, Yunnan Province, China"],
    ['TARI', "Taiwan Agricultural Research Institute. Taichung, Taiwan, China"],
    ['TAUI', "Tel Aviv University Entomological Collection, Israel"],
    ['THNHM', "Natural History Museum of the National Science Museum, Thailand"],
    ['TMSA', "Transvaal Museum. Transvaal, South Africa"],
    ['UASK', "Institute of Zoology, Ukrainian Academy of Science. Kiev, Ukraine"],
    ['UCDC', "University of California, Davis, R.M. Bohart Museum of Entomology. Davis, California, USA"],
    ['UFCE', "Universidade Federal do Ceará Fortaleza. Ceará, Brazil"],
    ['UFPE', "Departamento de Botânica, CCB. Recife, Pernambuco, Brazil"],
    ['UGBC', "Centre for the Study of Biological Diversity Georgetown, Guyana"],
    ['UKL', "University of Koblenz-Landau, Campus Landau, Germany"],
    ['UMSC', "Universiti Malaysia Sabah. Sabah, Malaysia"],
    ['UNAM', "Universidad Nacional Autonoma de Mexico. Mexico D. F., Mexico"],
    ['UOPJ', "Entomological Laboratory, University of Osaka Prefecture, Museum of Natural History. Osaka, Japan"],
    ['UPLB', "University of the Philippines. Los Baños, Philippines"],
    ['USCP', "University of San Carlos Entomological Collection. Cebu City, Philippines"],
    ['USNM', "(also NMNH) United States National Museum of Natural History. Washington D.C., USA"],
    ['NMNH', "(also USNM) United States National Museum of Natural History. Washington D.C., USA"],
    ['UTEP', "University of Texas at El Paso Centennial Museum. El Paso, Texas, USA"],
    ['UVGC', "Colección de Artrópodos. Guatemala City, Guatemala"],
    ['VNMN', "Vietnam National Museum of Nature Hanoi, Vietnam"],
    ['WAMP', "Western Australian Museum, Perth, Western Australia"],
    ['WMLC', "World Museum Liverpool, Liverpool, United Kingdom"],
    ['ZFMK', "Zoologisches Forschungsinstitut und Museum Alexander König Bonn, Germany"],
    ['ZHOU', "Shanyi Zhou, Guilin, Guangxi, China"],
    ['ZISP', "Zoological Institute of the Russian Academy of Sciences St. Petersburg, Russia"],
    ['ZMAN', "Instituut voor Taxonomische Zoologie, Zoologisch Museum. Universiteit van Amsterdam. Amsterdam, Netherlands"],
    ['ZMHB', "(also MNHU) Museum für Naturkunde der Humboldt-Universitat. Berlin, Germany"],
    ['MNHU', "(also ZMHB) Museum für Naturkunde der Humboldt-Universitat. Berlin, Germany"],
    ['ZMUA', "Zoological Museum of the University of Athens, Greece"],
    ['ZMUC', "Zoologisk Museum. University of Copenhagen. Copenhagen, Denmark"],
    ['ZMUH', "Zoologisches Institut und Museum der Universitat. Hamburg, Germany"],
    ['ZMUM', "Zoological Museum of the State University of Moscow, Russia"],
    ['ZSMC', "Zoologische Staatssammlung. Munich, Germany"],
  ]

  def self.up
    set_user_for_papertrail!
    create_institutions!
  end

  def self.down
    # No-op.
  end

  private
    def self.set_user_for_papertrail!
      antcat_bot_user_id = 62
      PaperTrail.whodunnit = antcat_bot_user_id
    end

    def self.create_institutions!
      INSTITUTIONS.each do |abbreviation, name|
        Institution.create!(abbreviation: abbreviation, name: name)
      end
    end
end

require 'spec_helper'

describe Bolton::SubfamilyCatalog do
  before do
    @subfamily_catalog = Bolton::SubfamilyCatalog.new
  end

  it "should parse the family" do
    @subfamily_catalog.import_html %{
<html><body><div class=Section1>

<p><b style="mso-bidi-font-weight:normal"><span lang="EN-GB"><p> </p></span></b></p>
<p><b><span lang=EN-GB>FAMILY FORMICIDAE<o:p></o:p></span></b></p>
<p><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Subfamilies of Formicidae (extant)</span></b><span lang=EN-GB>: Aenictinae, Myrmicinae<b style='mso-bidi-font-weight: normal'>.</b></span></p>
<p><b><span lang=EN-GB>Subfamilies of Formicidae (extinct)</span></b><span lang=EN-GB>: *Armaniinae, *Brownimeciinae.</span></p>

<p><b><span lang=EN-GB>Genera (extant) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>Condylodon, Hypochira</i>.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) <i>incertae sedis</i> in Formicidae</span></b><span lang=EN-GB>: <i>*Calyptites</i>.</span></p>

<p><b><span lang=EN-GB>Genera (extant) excluded from Formicidae</span></b><span lang=EN-GB>: <i><span style='color:green'>Formila</span></i>.</span></p>
<p><b><span lang=EN-GB>Genera (extinct) excluded from Formicidae</span></b><span lang=EN-GB>: *<i><span style='color:green'>Cariridris, Cretacoformica</span></i>.</span></p>

<p><b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in Formicidae</span></b><span lang=EN-GB>: <i><span style='color:purple'>Hypopheidole</span></i>.</span></p>

<p><b><span lang=EN-GB>Genera <i>incertae sedis</i> in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> *<b><i><span style='color:red'>CALYPTITES</span></i></b> </span></p>
<p>Calyptites taxonomic history</p>
<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>
<p><b><span lang=EN-GB>Genus</span></b><span lang=EN-GB> <b><i><span style='color:red'>CONDYLODON</span></i></b> </span></p>
<p>Condylodon taxonomic history</p>
<p><b><span lang=EN-GB>Genus <i><span style='color:green'>HYPOCHIRA</span></i> <o:p></o:p></span></b></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>SYNTAPHUS</span></i> <o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify'><span lang=EN-GB><o:p>&nbsp;</o:p></span></p>

<p><b><span lang=EN-GB>Genera excluded from <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>
<p><span lang=EN-GB>The following were all originally described as members of Formicidae but are now excluded.</span></p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:green'>CARIRIDRIS</span></i> <o:p></o:p></span></b></p>
<p>Cariridris taxonomic history</p>
<p><b><span lang=EN-GB>Genus *<i><span style='color:red'>CRETACOFORMICA</span></i> <o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>Unavailable family-group names in <span style='color:red'>FORMICIDAE</span><o:p></o:p></span></b></p>

<p><b><span lang=EN-GB>Genus-group <i>nomina nuda</i> in <span style='color:red'>FORMICIDAE<o:p></o:p></span></span></b></p>

</div></body></html>
    }

    taxon = Subfamily.find_by_name 'Aenictinae'
    taxon.should_not be_invalid
    taxon.should_not be_fossil
    taxon = Subfamily.find_by_name 'Myrmicinae'
    taxon.should_not be_invalid
    taxon.should_not be_fossil

    taxon = Subfamily.find_by_name 'Armaniinae'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon = Subfamily.find_by_name 'Brownimeciinae'
    taxon.should_not be_invalid
    taxon.should be_fossil

    taxon = Genus.find_by_name 'Condylodon'
    taxon.should_not be_invalid
    taxon.should_not be_fossil
    taxon.incertae_sedis_in.should == 'family'
    taxon.taxonomic_history.should == '<p>Condylodon taxonomic history</p>'

    taxon = Genus.find_by_name 'Calyptites'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon.incertae_sedis_in.should == 'family'
    taxon.taxonomic_history.should == '<p>Calyptites taxonomic history</p>'

    taxon = Genus.find_by_name 'Hypochira'
    taxon.status.should == 'unidentifiable'
    taxon.incertae_sedis_in.should == 'family'

    taxon = Genus.find_by_name 'Formila'
    taxon.should be_invalid
    taxon.should_not be_fossil
    taxon.status.should == 'excluded'

    taxon = Genus.find_by_name 'Cariridris'
    taxon.should be_invalid
    taxon.should be_fossil
    taxon.status.should == 'excluded'
    taxon.taxonomic_history.should == '<p>Cariridris taxonomic history</p>'

    taxon = Genus.find_by_name 'Hypopheidole'
    taxon.should be_invalid
    taxon.status.should == 'nomen nudus'

    taxon = Genus.find_by_name 'Syntaphus'
    taxon.should_not be_invalid
    taxon.should be_fossil
    taxon.incertae_sedis_in.should == 'family'
    taxon.taxonomic_history.should == ''

    taxon = Genus.find_by_name 'Cretacoformica'
    taxon.should be_invalid
    taxon.should be_fossil
    taxon.status.should == 'excluded'
    taxon.taxonomic_history.should == ''

  end

end

<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="Data">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Instance"  />
    <xs:element ref="Command"/>
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="TargetVersion" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='TargetVersion'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='ServicePack'/>
	  <xs:element name='TerminalServer' form='qualified' type='feEmptyElement' minOccurs='0'/>
	  <xs:element ref='Suites'/>
	  <xs:element ref='ProductType'/>
	</xs:sequence>

	<xs:attribute name='major' type='xs:nonNegativeInteger' use='required'/>
	<xs:attribute name='minor' type='xs:nonNegativeInteger' use='required'/>
	<xs:attribute name='build' type='xs:nonNegativeInteger' use='required' />
	<xs:attribute name='platform' type='xs:nonNegativeInteger' use='required'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name="ServicePack">
    <xs:complexType>
      <xs:simpleContent>
	<xs:extension base='xs:string'>
	  <xs:attribute name='major' type='xs:nonNegativeInteger' use='required'/>
	  <xs:attribute name='minor' type='xs:nonNegativeInteger' use='required'/>
	</xs:extension>
      </xs:simpleContent>
    </xs:complexType>
  </xs:element>

  <xs:element name='Suites'>
    <xs:complexType>
      <xs:simpleContent>
	<xs:extension base='feHex'>
	  <xs:attribute name='verSuiteBackOffice' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteCommunications' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteDataCenter' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteEmbeddedNt' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteEnterprise' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteSingleUserTs' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteSmallBusiness' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteSmallBusinessRestricted' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteTerminal' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuitePersonal' type='xs:boolean' use='required'/>
	  <xs:attribute name='verSuiteBlade' type='xs:boolean' use='required'/>
	</xs:extension>
      </xs:simpleContent>
    </xs:complexType>
  </xs:element>

  <xs:element name='ProductType' type='xs:nonNegativeInteger'/>

</xs:schema>

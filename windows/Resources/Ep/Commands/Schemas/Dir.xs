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
     <xs:element ref="Directory" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
    <xs:element ref="Error" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Directory'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='File' minOccurs='0' maxOccurs='unbounded'/>
	</xs:sequence>

	<xs:attribute name='path' type='xs:string' use='required'/>
	<xs:attribute name='denied' type='xs:boolean' use='optional'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='File'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='FileTime' minOccurs='3' maxOccurs='3'/>
	  <xs:choice minOccurs='0' maxOccurs='unbounded'>
	    <xs:element ref='FileAttributeDirectory'/>
	    <xs:element ref='FileAttributeArchive'/>
	    <xs:element ref='FileAttributeCompressed'/>
	    <xs:element ref='FileAttributeEncrypted'/>
	    <xs:element ref='FileAttributeHidden'/>
	    <xs:element ref='FileAttributeOffline'/>
	    <xs:element ref='FileAttributeReadonly'/>
	    <xs:element ref='FileAttributeSystem'/>
	    <xs:element ref='FileAttributeTemporary'/>
	  </xs:choice>
	</xs:sequence>

	<xs:attribute name='name' type='xs:string' use='required'/>
	<xs:attribute name='short' type='xs:string' use='required'/>
	<xs:attribute name='size' type='xs:unsignedLong' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='FileAttributeDirectory'/>
  <xs:element name='FileAttributeArchive'/>
  <xs:element name='FileAttributeCompressed'/>
  <xs:element name='FileAttributeEncrypted'/>
  <xs:element name='FileAttributeHidden'/>
  <xs:element name='FileAttributeOffline'/>
  <xs:element name='FileAttributeReadonly'/>
  <xs:element name='FileAttributeSystem'/>
  <xs:element name='FileAttributeTemporary'/>

  <xs:element name='FileTime'>
    <xs:complexType>
	<xs:simpleContent>
	  <xs:extension base='xs:dateTime'>
	    <xs:attribute name='type' type='timeType' use='required'/>
	    <xs:attribute name='locale' type='localeType' use='required'/>
	  </xs:extension>
	</xs:simpleContent>
    </xs:complexType>
  </xs:element>

<!-- Types -->
 <xs:simpleType name='localeType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='remotelocal'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='timeType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='modified'/>
    <xs:enumeration value='created'/>
    <xs:enumeration value='accessed'/>
  </xs:restriction>
 </xs:simpleType>

</xs:schema>


<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified" attributeFormDefault="unqualified">

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="Data">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Instance"  />
    <xs:element ref="Command"/>
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="Error" />
     <xs:element ref="IntermediateSuccess" />
     <xs:element ref="LocalGetDirectory" />
     <xs:sequence>
      <xs:element ref="FileStart" />
     <xs:element ref="Error" minOccurs="0" maxOccurs="unbounded"/>
      <xs:element ref="FileStop" />
     </xs:sequence>
    </xs:choice>
    <xs:element ref="Conclusion" minOccurs="0" />
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="LocalGetDirectory" type="feStringElementWithTimestamp" />

 <xs:element name="FileStart">
  <xs:complexType>
   <xs:sequence minOccurs="3" maxOccurs="3">
	<xs:element ref="FileTime"/>
   </xs:sequence>
   <xs:attribute name="implantName"         type="xs:string"             use="required" />
   <xs:attribute name="lptimestamp"         type="xs:dateTime"           use="required" />
   <xs:attribute name="realPath"            type="xs:string"             use="optional" />
   <xs:attribute name="size"                type="xs:nonNegativeInteger" use="required" />   
  </xs:complexType>
 </xs:element>

 <xs:element name="FileStop">
  <xs:complexType>
   <xs:attribute name="localName"           type="xs:string"             use="required" />
   <xs:attribute name="lptimestamp"         type="xs:dateTime"           use="required" />
   <xs:attribute name="size"                type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="status"              type="xs:string" use="required" />
   <xs:attribute name="error"               type="xs:string"                            />
  </xs:complexType>
 </xs:element>

 <xs:element name="Conclusion">
  <xs:complexType>
   <xs:attribute name="bytesTransfered"     type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="failedFiles"         type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lptimestamp"         type="xs:dateTime"           use="required" />
   <xs:attribute name="partialFiles"        type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="successFiles"        type="xs:nonNegativeInteger" use="required" />
  </xs:complexType>
 </xs:element>

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


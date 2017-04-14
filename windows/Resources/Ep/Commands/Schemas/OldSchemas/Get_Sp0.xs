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
   <xs:attribute name="implantName"         type="xs:string"             use="required" />
   <xs:attribute name="lptimestamp"         type="xs:dateTime"           use="required" />
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

</xs:schema>


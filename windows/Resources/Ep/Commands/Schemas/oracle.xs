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
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="PassFreelyMemCheckStart" />
     <xs:element ref="PassFreelyMemCheck" />
     <xs:element ref="PassFreelyOpenStart" />
     <xs:element ref="PassFreelyOpenSuccess" />
     <xs:element ref="PassFreelyCloseStart" />
     <xs:element ref="PassFreelyCloseSuccess" />
     <xs:element ref="OracleCrc" />
     <xs:element ref="ExtendedError" />
     <xs:element ref="Autoload" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice minOccurs="0">
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="PassFreelyOpenStart" type="feEmptyElementWithTimestamp"/>
 <xs:element name="PassFreelyOpenSuccess" type="feEmptyElementWithTimestamp"/>
 <xs:element name="PassFreelyCloseStart" type="feEmptyElementWithTimestamp"/>
 <xs:element name="PassFreelyCloseSuccess" type="feEmptyElementWithTimestamp"/>
 <xs:element name="PassFreelyMemCheckStart" type="feEmptyElementWithTimestamp"/>
 <xs:element name="PassFreelyMemCheck" type="feStringElementWithTimestamp"/>
 <xs:element name="OracleCrc"          type="feStringElementWithTimestamp"/>


 <xs:element name="Entry">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="LocalName"  form="qualified" type="xs:string" />
    <xs:element name="RemoteName" form="qualified" type="xs:string" />
    <xs:element name="Comment"    form="qualified" type="xs:string" />
    <xs:element name="Provider"   form="qualified" type="xs:string" />
    <xs:element name="Type"       form="qualified" type="xs:string" />
    <xs:element name="IPAddr"    form="qualified" type="xs:string" />
   </xs:sequence>
   <xs:attribute name="level"           type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lptimestamp"              type="xs:dateTime"           use="required" />
  </xs:complexType>
 </xs:element>


 <xs:element name="ExtendedError">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Error"  form="qualified" type="xs:string" />
    <xs:element name="Name" form="qualified" type="xs:string" />
   </xs:sequence>
   <xs:attribute name="code"      type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lptimestamp"              type="xs:dateTime"           use="required" />
  </xs:complexType>
 </xs:element>
</xs:schema>


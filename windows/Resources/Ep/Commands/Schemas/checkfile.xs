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
     <xs:element ref="Checkfile" />
     <xs:element ref="Autoload" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Checkfile">
  <xs:complexType>
   <xs:attribute name="check_checksum"           type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="check_date"               type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="check_length"             type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="check_time"               type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="checksum_match"           type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="dates_match"              type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="times_match"              type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lengths_match"            type="xs:nonNegativeInteger" use="required" />

   <xs:attribute name="checksum"                 type="xs:string"             use="required" />
   <xs:attribute name="last_save_dateTime"       type="xs:dateTime"           use="required" />
   <xs:attribute name="file_length"              type="xs:nonNegativeInteger" use="required" />

   <xs:attribute name="file_name"                type="xs:string"             use="required" />

   <xs:attribute name="lptimestamp"              type="xs:dateTime"           use="required" />

   <xs:attribute name="user_specified_checksum"  type="xs:string"             use="required" />
   <xs:attribute name="user_specified_dateTime"  type="xs:string"           use="required" />
   <xs:attribute name="user_specified_length"    type="xs:nonNegativeInteger" use="required" />
  </xs:complexType>
 </xs:element>
</xs:schema>

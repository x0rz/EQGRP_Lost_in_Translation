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
     <xs:element ref="Error" />
     <xs:element ref="FileAttribs" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="FileAttribs">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="FILE_ATTRIBUTE_ARCHIVE"             minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_COMPRESSED"          minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_DIRECTORY"           minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_ENCRYPTED"           minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_HIDDEN"              minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_NORMAL"              minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_OFFLINE"             minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_READONLY"            minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_REPARSE_POINT"       minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_SPARSE_FILE"         minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_SYSTEM"              minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_TEMPORARY"           minOccurs="0" form="qualified"/>
    <xs:element name="FILE_ATTRIBUTE_NOT_CONTENT_INDEXED" minOccurs="0" form="qualified"/>
   </xs:sequence>
   <xs:attribute name='attributeMask'  type='xs:string'             use='required'/>
   <xs:attribute name='accessedTime'   type='xs:dateTime'           use='required'/>
   <xs:attribute name='createdTime'    type='xs:dateTime'           use='required'/>
   <xs:attribute name='lptimestamp'    type='xs:dateTime'           use='required'/>
   <xs:attribute name='modifiedTime'   type='xs:dateTime'           use='required'/>
   <xs:attribute name='size'           type='xs:nonNegativeInteger' use='required'/>
  </xs:complexType>
 </xs:element>

</xs:schema>

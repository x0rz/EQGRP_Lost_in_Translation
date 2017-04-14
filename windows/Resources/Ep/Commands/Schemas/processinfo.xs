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
    <xs:choice minOccurs="0"  maxOccurs="unbounded">
     <xs:element ref="Error" />

     <xs:element ref="StartBasic" />
     <xs:element ref="BasicInfo"  />


     <xs:element ref="StartGroups" />
     <xs:element ref="GroupInfo"  />


     <xs:element ref="StartPrivs"  />
     <xs:element ref="Privilege"  />


     <xs:element ref="StartMods"  />
     <xs:element ref="Module"  />

    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="StartPrivs" type="feEmptyElementWithTimestamp"/>
 <xs:element name="StartGroups" type="feEmptyElementWithTimestamp" />
 <xs:element name="StartBasic" type="feEmptyElementWithTimestamp" />
 <xs:element name="StartMods" type="feEmptyElementWithTimestamp" />

 <xs:element name="User">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="user_type"   type="xs:string" />
     <xs:attribute name="user_attr"   type="xs:string" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Owner">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="owner_type"   type="xs:string" />
     <xs:attribute name="owner_attr"   type="xs:string" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Group">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="primaryGroup_type"   type="xs:string" />
     <xs:attribute name="primaryGroup_attr"   type="xs:string" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="BasicInfo">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="User"/>
    <xs:element ref="Owner"/>
    <xs:element ref="Group"/>
   </xs:sequence>
   <xs:attribute name="lptimestamp"   type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="GroupInfo">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="SE_GROUP_ENABLED" minOccurs="0"/>
    <xs:element ref="SE_GROUP_ENABLED_BY_DEFAULT" minOccurs="0"/>
    <xs:element ref="SE_GROUP_LOGON_ID" minOccurs="0"/>
    <xs:element ref="SE_GROUP_MANDATORY" minOccurs="0"/>
    <xs:element ref="SE_GROUP_OWNER" minOccurs="0"/>
    <xs:element ref="SE_GROUP_RESOURCE" minOccurs="0"/>
    <xs:element ref="SE_GROUP_USE_FOR_DENY_ONLY" minOccurs="0"/>
   </xs:sequence>
   <xs:attribute name="name" type="xs:string" use="required"/>
   <xs:attribute name="type" type="xs:string" use="required"/>
   <xs:attribute name="attr" type="xs:string" use="required"/>
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>


 <xs:element name="SE_GROUP_ENABLED" />
 <xs:element name="SE_GROUP_ENABLED_BY_DEFAULT" />
 <xs:element name="SE_GROUP_LOGON_ID" />
 <xs:element name="SE_GROUP_MANDATORY" />
 <xs:element name="SE_GROUP_OWNER" />
 <xs:element name="SE_GROUP_RESOURCE" />
 <xs:element name="SE_GROUP_USE_FOR_DENY_ONLY" />

 <xs:element name="Privilege">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="SE_PRIVILEGE_ENABLED_BY_DEFAULT" minOccurs="0"/>
    <xs:element ref="SE_PRIVILEGE_ENABLED" minOccurs="0"/>
   </xs:sequence>
   <xs:attribute name="name" type="xs:string" use="required"/>
   <xs:attribute name="attributes" type="xs:string" use="required"/>
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="SE_PRIVILEGE_ENABLED_BY_DEFAULT" type="feEmptyElement"/>
 <xs:element name="SE_PRIVILEGE_ENABLED" type="feEmptyElement"/>

 <xs:element name="Module">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Checksum"/>
    <xs:element ref="ModuleName"/>
   </xs:sequence>
   <xs:attribute name="base_address" type="xs:string" use="required"/>
   <xs:attribute name="entry_point" type="xs:string" use="required"/>
   <xs:attribute name="image_size" type="xs:string" use="required"/>
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Checksum" type="xs:string"/>
 <xs:element name="ModuleName" type="xs:string"/>

 <xs:element name="String">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
     <xs:attribute name="offset"      type="xs:nonNegativeInteger" />
     <xs:attribute name="unicode"     type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

</xs:schema>

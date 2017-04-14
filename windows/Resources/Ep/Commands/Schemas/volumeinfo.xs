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
     <xs:element ref="VolumeInfo" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="VolumeInfo">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="SerialNumber" />
    <xs:element ref="VolumeName" />
    <xs:element ref="FileSystemName" />
    <xs:element ref="Flags" />
   </xs:sequence>
   <xs:attribute name='lptimestamp'   type='xs:dateTime'           use='required'/>
   <xs:attribute name='maximumComponentLength'   type='xs:nonNegativeInteger'           use='required'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="SerialNumber">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="value"      type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="VolumeName"     type="xs:string" />
 <xs:element name="FileSystemName" type="xs:string" />

 <xs:element name="Flags">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="FS_CASE_IS_PRESERVED"         form="qualified" minOccurs="0"/>
    <xs:element name="FS_CASE_SENSITIVE"            form="qualified" minOccurs="0"/>
    <xs:element name="FS_UNICODE_STORED_ON_DISK"    form="qualified" minOccurs="0"/>
    <xs:element name="FS_PERSISTENT_ACLS"           form="qualified" minOccurs="0"/>
    <xs:element name="FS_FILE_COMPRESSION"          form="qualified" minOccurs="0"/>
    <xs:element name="FS_VOL_IS_COMPRESSED"         form="qualified" minOccurs="0"/>
    <xs:element name="FILE_NAMED_STREAMS"           form="qualified" minOccurs="0"/>
    <xs:element name="FILE_SUPPORTS_ENCRYPTION"     form="qualified" minOccurs="0"/>
    <xs:element name="FILE_SUPPORTS_OBJECT_IDS"     form="qualified" minOccurs="0"/>
    <xs:element name="FILE_SUPPORTS_REPARSE_POINTS" form="qualified" minOccurs="0"/>
    <xs:element name="FILE_SUPPORTS_SPARSE_FILES"   form="qualified" minOccurs="0"/>
    <xs:element name="FILE_VOLUME_QUOTAS"           form="qualified" minOccurs="0"/>
   </xs:sequence>
   <xs:attribute name='value'   type='xs:string'           use='required'/>
  </xs:complexType>
 </xs:element>

</xs:schema>

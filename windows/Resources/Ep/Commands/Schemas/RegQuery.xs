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
     <xs:element ref="Key" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

  <xs:element name='Key'>
    <xs:complexType>
	<xs:sequence>
	  <xs:element ref='Subkey' minOccurs='0' maxOccurs='unbounded'/>
	  <xs:element ref='Value' minOccurs='0' maxOccurs='unbounded'/>
	</xs:sequence>

	<xs:attribute name='hive' type='feHive' use='required'/>
	<xs:attribute name='name' type='xs:string' use='required'/>
	<xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name="Subkey">
    <xs:complexType>
	<xs:attribute name='name' type='xs:string' use='required'/>
    </xs:complexType>
  </xs:element>

  <xs:element name='Value'>
    <xs:complexType>
      <xs:simpleContent>
	<xs:extension base='xs:string'>
	  <xs:attribute name='name' type='xs:string' use='required'/>
	  <xs:attribute name='type' type='feValueType' use='required'/>
	  <xs:attribute name='typeValue' type='feHex' use='required'/>
	</xs:extension>
      </xs:simpleContent>
    </xs:complexType>
  </xs:element>

<!-- Types -->
 <xs:simpleType name='feHive'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='HKEY_LOCAL_MACHINE'/>
    <xs:enumeration value='HKEY_CLASSES_ROOT'/>
    <xs:enumeration value='HKEY_CURRENT_USER'/>
    <xs:enumeration value='HKEY_CURRENT_CONFIG'/>
    <xs:enumeration value='HKEY_USERS'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='feValueType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='REG_SZ'/>
    <xs:enumeration value='REG_EXPAND_SZ'/>
    <xs:enumeration value='REG_BINARY'/>
    <xs:enumeration value='REG_DWORD'/>
    <xs:enumeration value='REG_DWORD_BIG_ENDIAN'/>
    <xs:enumeration value='REG_LINK'/>
    <xs:enumeration value='REG_MULTI_SZ'/>
    <xs:enumeration value='REG_RESOURCE_LIST'/>
    <xs:enumeration value='REG_FULL_RESOURCE_DESCRIPTOR'/>
    <xs:enumeration value='REG_RESOURCE_REQUIREMENTS_LIST'/>
    <xs:enumeration value='REG_QWORD'/>
    <xs:enumeration value='REG_NONE'/>
  </xs:restriction>
 </xs:simpleType>

</xs:schema>

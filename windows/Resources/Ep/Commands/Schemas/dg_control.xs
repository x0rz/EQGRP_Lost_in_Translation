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
     <xs:element ref="Version" />
     <xs:element ref="Status" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Status">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="LastTriggerTime" form="qualified">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base="xs:dateTime">
					<xs:attribute name="locale" type="remoteGmtType" use="required"/>
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
    </xs:element>
    <xs:element name="RegisteredProcess" form="qualified">
		<xs:complexType>
			<xs:simpleContent>
				<xs:extension base="feEmptyElement">
					<xs:attribute name="pid" type="xs:nonNegativeInteger" use="required"/>
					<xs:attribute name="mailslot" type="xs:string" use="required"/>
				</xs:extension>
			</xs:simpleContent>
		</xs:complexType>
    </xs:element>
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Version">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElementWithTimestamp">
		<xs:attribute name="major"     type="xs:nonNegativeInteger" use="required"/>
		<xs:attribute name="minor"     type="xs:nonNegativeInteger" use="required"/>
		<xs:attribute name="build"     type="xs:nonNegativeInteger" use="required"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:simpleType name='remoteGmtType'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value="remotegmt"/>
  </xs:restriction>
 </xs:simpleType>
 
</xs:schema>


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
     <xs:element ref="User" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="User">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Flags" />
    <xs:element form="qualified" type="AdUserTime" minOccurs="0" name="AccountExpirationDate" />
    <xs:element form="qualified" type="AdUserTime" minOccurs="0" name="LastFailedLogin" />
    <xs:element form="qualified" type="AdUserTime" minOccurs="0" name="LastLogin" />
    <xs:element form="qualified" type="AdUserTime" minOccurs="0" name="LastLogoff" />
    <xs:element form="qualified" type="AdUserTime" minOccurs="0" name="PasswordExpirationDate" />
    <xs:element form="qualified" type="AdUserTime" minOccurs="0" name="PasswordLastChanged" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="Department" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="Description" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="EmailAddress" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="LastName" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="FirstName" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="FullName" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="HomeDirectory" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="HomePage" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="LoginScript" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="Manager" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="TelephoneNumber" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="TelephoneHome" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="TelephoneMobile" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="TelephonePager" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="FaxNumber" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="OfficeLocations" />
    <xs:element form="qualified" type="xs:string" minOccurs="0"  name="Name" />
   </xs:sequence>
   <xs:attribute name="badLoginCount" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="maxStorage" type="xs:nonNegativeInteger" use="required"/>
   <xs:attribute name="passwordMinimumLength" type="xs:nonNegativeInteger" use="required"/>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Flags">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="AccountDisabled" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsAccountLocked" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="PasswordRequired" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="RequireUniquePassword" />
   </xs:sequence>
  </xs:complexType>  
 </xs:element>

  <xs:complexType name="AdUserTime">
   <xs:simpleContent>
    <xs:extension base="xs:dateTime">
     <xs:attribute name="locale"      type="xs:string" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>


</xs:schema>

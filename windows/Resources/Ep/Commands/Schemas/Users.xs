<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley" xmlns='urn:ddb:expandingpulley' xmlns:xs="http://www.w3.org/2001/XMLSchema" >

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
    <xs:element name="Name"              type="xs:string"  form="qualified" />
    <xs:element name="Comment"           type="xs:string"  form="qualified" />
    <xs:element name="FullName"          type="xs:string"  form="qualified" />
    <xs:element name="LastLogon"         type="feDateTime" form="qualified" />
    <xs:element name="AcctExpires"       type="feDateTime" form="qualified" />
    <xs:element name="PasswdLastChanged" type="feDateTime" form="qualified" />
    <xs:element name="Privilege"         type="feDateTime" form="qualified" />
    <xs:element ref="Flags"/>
   </xs:sequence>
   <xs:attribute name="user_id"                    type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="primary_group_id"           type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="num_logons"                 type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="passwd_expired"             type="xs:boolean" use="required" />
   <xs:attribute name="lptimestamp"                type="xs:dateTime"           use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Flags">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="AuthFlags"/>
    <xs:element ref="AccountFlags"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="AuthFlags">
  <xs:complexType>
   <xs:sequence>
    <xs:element minOccurs="0" form="qualified" name="AfOpPrint"    />
    <xs:element minOccurs="0" form="qualified" name="AfOpComm"     />
    <xs:element minOccurs="0" form="qualified" name="AfOpServer"   />
    <xs:element minOccurs="0" form="qualified" name="AfOpAccounts" />
   </xs:sequence>
   <xs:attribute name="mask" type="feHex" />
  </xs:complexType>
 </xs:element>
	
 <xs:element name="AccountFlags">
  <xs:complexType>
   <xs:sequence>
    <xs:element minOccurs="0" form="qualified" name="UfScript" />
    <xs:element minOccurs="0" form="qualified" name="UfAccountDisable" />
    <xs:element minOccurs="0" form="qualified" name="UfHomedirRequired" />
    <xs:element minOccurs="0" form="qualified" name="UfPasswdNotReqd" />
    <xs:element minOccurs="0" form="qualified" name="UfPasswdCantChange" />
    <xs:element minOccurs="0" form="qualified" name="UfLockout" />
    <xs:element minOccurs="0" form="qualified" name="UfDontExpirePasswd" />
    <xs:element minOccurs="0" form="qualified" name="UfEncryptedTextPasswordAllowed" />
    <xs:element minOccurs="0" form="qualified" name="UfNotDelegated" />
    <xs:element minOccurs="0" form="qualified" name="UfSmartcardRequired" />
    <xs:element minOccurs="0" form="qualified" name="UfUseDesKeyOnly" />
    <xs:element minOccurs="0" form="qualified" name="UfDontRequirePreauth" />
    <xs:element minOccurs="0" form="qualified" name="UfTrustedForDelegation" />
    <xs:element minOccurs="0" form="qualified" name="UfPasswordExpired" />
    <xs:element minOccurs="0" form="qualified" name="UfTrustedToAuthenticateForDelegation" />
    <xs:element minOccurs="0" form="qualified" name="UfNormalAccount" />
    <xs:element minOccurs="0" form="qualified" name="UfTempDuplicateAccount" />
    <xs:element minOccurs="0" form="qualified" name="UfWorkstationTrustAccount" />
    <xs:element minOccurs="0" form="qualified" name="UfServerTrustAccount" />
    <xs:element minOccurs="0" form="qualified" name="UfInterdomainTrustAccount" />
   </xs:sequence>
   <xs:attribute name="mask" type="feHex" />
  </xs:complexType>
 </xs:element>

 <xs:complexType name="feDateTime">
  <xs:simpleContent>
   <xs:extension base="xs:string">
    <xs:attribute name="locale"  type="xs:string" />
   </xs:extension>
  </xs:simpleContent>
 </xs:complexType>

</xs:schema>

<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="User">
  <xsl:text>-------------User Account Information------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text> Personal Data for </xsl:text>
  <xsl:value-of select="Name" />
  <xsl:text>:</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'First Name'" />
   <xsl:with-param name="value" select="FirstName/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Last Name'" />
   <xsl:with-param name="value" select="LastName/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Display Name'" />
   <xsl:with-param name="value" select="FullName/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Department'" />
   <xsl:with-param name="value" select="Department/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Description'" />
   <xsl:with-param name="value" select="Description/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'EmailAddress'" />
   <xsl:with-param name="value" select="EmailAddress/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Manager'" />
   <xsl:with-param name="value" select="Manager/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'OfficeLocations'" />
   <xsl:with-param name="value" select="OfficeLocations/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintReturn" />
  <xsl:text> Account Information:</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintDate">
   <xsl:with-param name="name" select="'Account Expiration'" />
   <xsl:with-param name="value" select="AccountExpirationDate/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintDate">
   <xsl:with-param name="name" select="'LastFailedLogin'" />
   <xsl:with-param name="value" select="AccountExpirationDate/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintDate">
   <xsl:with-param name="name" select="'LastLogin'" />
   <xsl:with-param name="value" select="LastLogin/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintDate">
   <xsl:with-param name="name" select="'LastLogoff'" />
   <xsl:with-param name="value" select="LastLogoff/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintBool">
   <xsl:with-param name="name" select="'Account Disabled'" />
   <xsl:with-param name="value" select="not(boolean(Flags/AccountDisabled))"    />
  </xsl:call-template>

  <xsl:call-template name="PrintBool">
   <xsl:with-param name="name" select="'Account Locked'" />
   <xsl:with-param name="value" select="not(boolean(Flags/IsAccountLocked))"    />
  </xsl:call-template>

  <xsl:text>&#x09;BadLoginCount : </xsl:text>
  <xsl:value-of select="@badLoginCount" />
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintReturn" />
  <xsl:text> Password Information:</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:text>&#x09;Minimum Length(0=unknown) : </xsl:text>
  <xsl:value-of select="@passwordMinimumLength" />
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintBool">
   <xsl:with-param name="name" select="'Required'" />
   <xsl:with-param name="value" select="not(boolean(Flags/PasswordRequired))"    />
  </xsl:call-template>

  <xsl:call-template name="PrintDate">
   <xsl:with-param name="name" select="'Expiration Date'" />
   <xsl:with-param name="value" select="PasswordExpirationDate/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintDate">
   <xsl:with-param name="name" select="'Last Changed'" />
   <xsl:with-param name="value" select="PasswordLastChanged/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintReturn" />
  <xsl:text> Telephone Numbers:</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Office'" />
   <xsl:with-param name="value" select="TelephoneNumber/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Home'" />
   <xsl:with-param name="value" select="TelephoneHome/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Mobile'" />
   <xsl:with-param name="value" select="TelephoneMobile/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Pager'" />
   <xsl:with-param name="value" select="TelephonePager/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Fax Number'" />
   <xsl:with-param name="value" select="FaxNumber/."    />
  </xsl:call-template>


  <xsl:call-template name="PrintReturn" />
  <xsl:text> Additional Data:</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'Home Directory'" />
   <xsl:with-param name="value" select="HomeDirectory/."    />
  </xsl:call-template>

  <xsl:text>&#x09;MaxStorage(0=unknown) : </xsl:text>
  <xsl:value-of select="@maxStorage" />
  <xsl:call-template name="PrintReturn" />

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'HomePage'" />
   <xsl:with-param name="value" select="HomePage/."    />
  </xsl:call-template>

  <xsl:call-template name="PrintString">
   <xsl:with-param name="name" select="'LoginScript'" />
   <xsl:with-param name="value" select="LoginScript/."    />
  </xsl:call-template>
 </xsl:template>

 <xsl:template name="PrintString">
  <xsl:param name="name" />
  <xsl:param name="value" />
  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="$name" />
  <xsl:text> : </xsl:text>
  <xsl:choose>
   <xsl:when test="string-length($value) &gt; 0">
    <xsl:value-of select="$value" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>Unknown</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template name="PrintDate">
  <xsl:param name="name" />
  <xsl:param name="value" />
  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="$name" />
  <xsl:text> : </xsl:text>
  <xsl:choose>
   <xsl:when test="$value">
    <xsl:call-template name="printTimeMDYHMS">
     <xsl:with-param name="i" select="$value" />
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>Unknown</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template name="PrintBool">
  <xsl:param name="name" />
  <xsl:param name="value" />
  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="$name" />
  <xsl:text> : </xsl:text>
  <xsl:choose>
   <xsl:when test="$value = true">
    <xsl:text>Yes</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>No</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>
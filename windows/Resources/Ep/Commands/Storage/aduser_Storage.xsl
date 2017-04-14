<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="User"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="User">
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">account_disabled</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintBool">
        <xsl:with-param name="value" select="not(boolean(Flags/AccountDisabled))" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">account_locked</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintBool">
        <xsl:with-param name="value" select="not(boolean(Flags/IsAccountLocked))" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">password_reqd</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintBool">
        <xsl:with-param name="value" select="not(boolean(Flags/PasswordRequired))" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">bad_login_count</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@badLoginCount" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">password_min_length</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@passwordMinimumLength" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_storage</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@maxStorage" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">home_directory</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="HomeDirectory" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">login_script</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="LoginScript" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">home_page</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="HomePage" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">fax</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="FaxNumber" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">pager</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="TelephonePager" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">mobile_phone</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="TelephoneMobile" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">office_phone</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="TelephoneNumber" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">home_phone</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintString">
        <xsl:with-param name="value" select="TelephoneHome" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">password_last_changed</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintDate">
        <xsl:with-param name="value" select="PasswordLastChanged" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">password_exp_date</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintDate">
        <xsl:with-param name="value" select="PasswordExpirationDate" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_logoff</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintDate">
        <xsl:with-param name="value" select="LastLogoff" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>


    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_failed_login</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintDate">
        <xsl:with-param name="value" select="LastFailedLogin" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_login</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintDate">
        <xsl:with-param name="value" select="LastLogin" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">account_expiration</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="PrintDate">
        <xsl:with-param name="value" select="AccountExpirationDate" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">office_locations</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="OfficeLocations" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">manager</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Manager" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">email_address</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="EmailAddress" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">department</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Department" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">description</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Description" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">first_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="FirstName" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="LastName" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">display_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="FullName" /></xsl:attribute>
    </xsl:element>
  </xsl:template>


 <xsl:template name="PrintString">
  <xsl:param name="value" />
  <xsl:choose>
   <xsl:when test="string-length($value) &gt; 0">
    <xsl:value-of select="$value" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>Unknown</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="PrintDate">
  <xsl:param name="value" />
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
 </xsl:template>

 <xsl:template name="PrintBool">
  <xsl:param name="value" />
  <xsl:text>&#x09;</xsl:text>
  <xsl:choose>
   <xsl:when test="$value = true">
    <xsl:text>true</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>false</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


</xsl:transform>
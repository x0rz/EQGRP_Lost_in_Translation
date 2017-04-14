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
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">full_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="FullName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">comment</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Comment"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">privilege</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Privilege"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">user_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@user_id"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">primary_group_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@primary_group_id"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_logon</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>

        <xsl:when test="contains(LastLogon/., 'T')">
         <xsl:call-template name="printTimeMDYHMS">
          <xsl:with-param name="i" select="LastLogon" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <xsl:value-of select="LastLogon"/>
        </xsl:otherwise>

       </xsl:choose>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">num_logons</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@num_logons"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">acct_expires</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="contains(AcctExpires, 'T')">
         <xsl:call-template name="printTimeMDYHMS">
          <xsl:with-param name="i" select="AcctExpires/." />
         </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="AcctExpires"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">passwd_last_changed</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:choose>
        <xsl:when test="contains(PasswdLastChanged, 'T')">
         <xsl:call-template name="printTimeMDYHMS">
          <xsl:with-param name="i" select="PasswdLastChanged/." />
         </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="PasswdLastChanged"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">passwd_expired</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@passwd_expired" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">auth_flags</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Flags/AuthFlags/@mask"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">auth_op_print</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AuthFlags/AfOpPrint">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">auth_op_comm</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AuthFlags/AfOpComm">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">auth_op_server</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AuthFlags/AfOpServer">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">auth_op_accts</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AuthFlags/AfOpAccounts">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">acct_flags</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Flags/AccountFlags/@mask"/></xsl:attribute>
    </xsl:element>



    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">script</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfScript">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">acct_disable</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfAccountDisable">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">UfPasswordExpired</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfPasswordExpired">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">UfTrustedToAuthenticateForDelegation</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfTrustedToAuthenticateForDelegation">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">homedir_reqd</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfHomedirRequired">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">passwd_not_reqd</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfPasswdNotReqd">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">passwd_cant_change</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfPasswdCantChange">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">lockout</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfLockout">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">dont_expire_passwd</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfDontExpirePasswd">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">trusted_for_deleg</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfTrustedForDelegation">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">encrypted_text_passwd_allw</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfEncryptedTextPasswordAllowed">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">not_delegated</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfNotDelegated">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">smartcard_reqd</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfSmartCardRequired">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">use_des_key_only</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfUseDesKeyOnly">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">dont_require_preauth</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfDontRequirePreauth">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">normal_acct</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfNormalAccount">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">temp_duplicate_acct</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfTempDuplicateAccount">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">workstat_trust_acct</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfWorkstationTrustAccount">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">server_trust_acct</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfServerTrustAccount">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">interdomain_trust_acct</xsl:attribute>
      <xsl:choose>
	<xsl:when test="Flags/AccountFlags/UfInterdomainTrustAccount">
	  <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>

  </xsl:template>

</xsl:transform>
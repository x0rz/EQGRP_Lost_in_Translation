<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="User">

  <xsl:text>            Name  : </xsl:text>
   <xsl:value-of select="Name" />
   <xsl:text> (</xsl:text>
   <xsl:value-of select="@full_name" />
   <xsl:text>)</xsl:text>

  <xsl:call-template name="PrintReturn" />
  <xsl:text>          Comment : </xsl:text>
   <xsl:value-of select="Comment" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>               Id : </xsl:text>
   <xsl:value-of select="@user_id" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>     Pimary Group : </xsl:text>
   <xsl:value-of select="@primary_group_id" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>       Last Logon : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(LastLogon, 'T')">
     <xsl:call-template name="printTimeMDYHMS">
      <xsl:with-param name="i" select="LastLogon" />
     </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="LastLogin" />
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>      # of Logons : </xsl:text>
   <xsl:value-of select="@num_logons" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>     Acct Expires : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(AcctExpires, 'T')">
     <xsl:call-template name="printTimeMDYHMS">
      <xsl:with-param name="i" select="AcctExpires" />
     </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="AcctExpires" />
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>Pass Last Changed : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(PasswdLastChanged, 'T')">
     <xsl:call-template name="printTimeMDYHMS">
      <xsl:with-param name="i" select="PasswdLastChanged" />
     </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="PasswdLastChanged" />
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>     Pass Expired : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(@passwd_expired, 'true')">
     <xsl:text>Yes</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>No</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>       Privileges : </xsl:text>
   <xsl:value-of select="Privilege" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>   Auths (</xsl:text>
   <xsl:value-of select="Flags/AuthFlags/@mask" />
  <xsl:text>) : </xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:if test="Flags/AuthFlags/AfOpPrint">
   <xsl:text>&#x09;The print operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:if test="Flags/AuthFlags/AfOpComm">
   <xsl:text>&#x09;The communications operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:if test="Flags/AuthFlags/AfOpServer">
   <xsl:text>&#x09;The server operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:if test="Flags/AuthFlags/AfOpAccounts">
   <xsl:text>&#x09;The accounts operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:text>  Flags (</xsl:text>
   <xsl:value-of select="Flags/AccountFlags/@mask" />
  <xsl:text>) : </xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:for-each select="Flags/AccountFlags/*">
   <xsl:text>&#x09;</xsl:text>
   <xsl:value-of select="name(.)" /> 
   <xsl:call-template name="PrintReturn" />
  </xsl:for-each>

  <xsl:text>-------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>
</xsl:transform>
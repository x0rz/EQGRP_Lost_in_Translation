<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="include/StandardTransforms.xsl"/>

 <xsl:template match="Users">
	<xsl:apply-templates select="User"/>
 </xsl:template>
 
 <xsl:template match="User">

  <xsl:text>                        Name  : </xsl:text>
   <xsl:value-of select="Name" />
   <xsl:text> (</xsl:text>
   <xsl:value-of select="FullName" />
   <xsl:text>)</xsl:text>

  <xsl:call-template name="PrintReturn" />
  <xsl:text>                      Comment : </xsl:text>
   <xsl:value-of select="Comment" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>                           Id : </xsl:text>
   <xsl:value-of select="@userId" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>                Primary Group : </xsl:text>
   <xsl:value-of select="@primaryGroupId" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>               Home Directory : </xsl:text>
   <xsl:value-of select="HomeDir" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>                   User Shell : </xsl:text>
   <xsl:value-of select="UserShell" />
  <xsl:call-template name="PrintReturn" />

<xsl:if test="LastLogon">
  <xsl:text>                   Last Logon : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(LastLogon, 'T')">
       <xsl:value-of select="substring-before(LastLogon, 'T')"/>
       <xsl:text> </xsl:text>
       <xsl:value-of select="substring-before(substring-after(LastLogon, 'T'), '.')"/>
       <xsl:text> </xsl:text>
    </xsl:when>
    <xsl:when test="NeverLoggedOn">
	<xsl:text>Never</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text> </xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="PrintReturn" />
</xsl:if>

	<xsl:if test="@numLogons">
  <xsl:text>                  # of Logons : </xsl:text>
   <xsl:value-of select="@numLogons" />
  <xsl:call-template name="PrintReturn" />
	</xsl:if>

<xsl:if test="AcctNeverExpires or AcctExpires">
  <xsl:text>              Account Expires : </xsl:text>
   <xsl:choose>
    <xsl:when test="contains(AcctExpires, 'T')">
       <xsl:value-of select="substring-before(AcctExpires, 'T')"/>
       <xsl:text> </xsl:text>
       <xsl:value-of select="substring-before(substring-after(AcctExpires, 'T'), '.')"/>
       <xsl:text> </xsl:text>
    </xsl:when>
    <xsl:when test="AcctNeverExpires">
      <xsl:text>Never</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>Unknown</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  <xsl:call-template name="PrintReturn" />
  	</xsl:if>

	<xsl:if test="PasswdLastChanged or PasswdNeverChanged">
		<xsl:text>Passwd Changed (Elapsed Time) : </xsl:text>
		<xsl:choose>
		<xsl:when test="PasswdNeverChanged or (PasswdLastChanged/@type = 'invalid')">
			<xsl:text>Never</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="days" select="substring-before(substring-after(PasswdLastChanged, 'P'), 'D')" />
			<xsl:variable name="hours" select="substring-before(substring-after(PasswdLastChanged, 'T'), 'H')" />
			<xsl:variable name="minutes" select="substring-before(substring-after(PasswdLastChanged, 'H'), 'M')" />
			<xsl:variable name="seconds" select="substring-before(substring-after(PasswdLastChanged, 'M'), '.')" />
			<xsl:value-of select="$days"/>
			<xsl:text>d</xsl:text>
			<xsl:value-of select="$hours"/>
			<xsl:text>h</xsl:text>
			<xsl:value-of select="$minutes"/>
			<xsl:text>m</xsl:text>
			<xsl:value-of select="$seconds"/>
			<xsl:text>s</xsl:text>
		</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
	</xsl:if>

	<xsl:if test="@passwdExpired">
		<xsl:text>             Password Expired : </xsl:text>
		<xsl:choose>
			<xsl:when test="contains(@passwdExpired, 'true')">
				<xsl:text>Yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>No</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
  	</xsl:if>

	<xsl:if test="Privilege">
		<xsl:text>                   Privileges : </xsl:text>
		<xsl:value-of select="Privilege" />
		<xsl:call-template name="PrintReturn" />
	</xsl:if>

	<xsl:if test="Flags">
		<xsl:text>          Authorization Flags : (</xsl:text>
		<xsl:value-of select="Flags/AuthFlags/@mask" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />

		<xsl:if test="Flags/AuthFlags/AfOpPrint">
			<xsl:text>                                The print operator privilege is enabled.</xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>

  <xsl:if test="Flags/AuthFlags/AfOpComm">
   <xsl:text>                                The communications operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:if test="Flags/AuthFlags/AfOpServer">
   <xsl:text>                                The server operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:if test="Flags/AuthFlags/AfOpAccounts">
   <xsl:text>                                The accounts operator privilege is enabled.</xsl:text>
   <xsl:call-template name="PrintReturn" />
  </xsl:if>

  <xsl:text>                Account Flags : (</xsl:text>
   <xsl:value-of select="Flags/AccountFlags/@mask" />
   <xsl:text>)</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:for-each select="Flags/AccountFlags/*">
   <xsl:text>                                </xsl:text>
   <xsl:value-of select="name(.)" /> 
   <xsl:call-template name="PrintReturn" />
  </xsl:for-each>
  	</xsl:if>

  <xsl:text>-----------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>

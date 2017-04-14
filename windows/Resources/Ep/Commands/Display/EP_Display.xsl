<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Background">Command <xsl:value-of select="@request"/> moved to the background<xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Break">Received confirmation of BREAK request<xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="CommandStart">
    <xsl:if test="@background = 'yes'">Command <xsl:value-of select="@request"/> started in the background
</xsl:if>
  </xsl:template>

  <xsl:template match="ImplantVersion">       Implant : <xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Info"><xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="ListeningPostVersion">Listening Post : <xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="MemoryLeak">MEMORY LEAK : command='<xsl:value-of select="@command"/>' address='<xsl:value-of select="@address"/>' size='<xsl:value-of select="@size"/>'<xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Quit">Received confirmation of QUIT request<xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="SessionKey">   Session Key : <xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="TargetVersion">Target Version : <xsl:value-of select="@major"/>.<xsl:value-of select="@minor"/> (build <xsl:value-of select="@build"/>)
    <xsl:choose>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 4)">             Windows NT
	</xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 5) and (number(@minor) = 0)">             Windows 2000
	</xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 5) and (number(@minor) = 1)">             Windows XP
	</xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 5) and (number(@minor) = 2)">             Windows 2003
	</xsl:when>
	<xsl:when test="(number(@platform) = 2) and (number(@major) = 6)">             Windows Vista
	</xsl:when>

	<xsl:when test="(number(@platform) = 1) and (number(@major) = 4) and (number(@minor) = 0)">             Windows 95
	</xsl:when>
	<xsl:when test="(number(@platform) = 1) and (number(@major) = 4) and (number(@minor) = 10)">             Windows 98
	</xsl:when>
	<xsl:when test="(number(@platform) = 1) and (number(@major) = 4) and (number(@minor) = 90)">             Windows ME
	</xsl:when>

	<xsl:otherwise>                 Unmatched OS (platform <xsl:value-of select="@platform"/>)
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Timestamp">
	<xsl:value-of select="substring-before(., 'T')"/>
	<xsl:text> </xsl:text>
	<xsl:value-of select="substring-after(., 'T')"/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="Warning"><xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <!-- ignore types -->
  <xsl:template match="Command"/>
  <xsl:template match="CommandChannel"/>
  <xsl:template match="CommandEnd"/>
  <xsl:template match="CommandLog"/>
  <xsl:template match="CommandXml"/>
  <xsl:template match="Debug"/>
  <xsl:template match="RotateLog"/>
  <xsl:template match="UserInput"/>

  <!-- functions -->
  <xsl:template name="Return"><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:template>

</xsl:transform>
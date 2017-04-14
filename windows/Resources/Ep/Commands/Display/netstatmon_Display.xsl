<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Connection">
   <xsl:call-template name="printTimeHMS">
    <xsl:with-param name="i" select="@lptimestamp" />
   </xsl:call-template>
   <xsl:text> </xsl:text>
   <xsl:value-of select="@setting" />
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="8 - string-length(@setting)" />
   </xsl:call-template>
   <xsl:value-of select="@type"/>
   <xsl:text> </xsl:text>
   <xsl:choose>
    <xsl:when test="@valid = false">
     <xsl:text>*</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text> </xsl:text>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:text> </xsl:text>
   <xsl:value-of select="@localIp"/>
   <xsl:text>:</xsl:text>
   <xsl:value-of select="@localPort"/>

   <xsl:if test="contains(@type, 'TCP')">
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="30 - (string-length(@localIp) + string-length(@localPort) + 1)" />
   </xsl:call-template>
   <xsl:value-of select="@remoteIp"/>
   <xsl:text>:</xsl:text>
   <xsl:value-of select="@remotePort"/>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="30 - (string-length(@remoteIp) + string-length(@remotePort) + 1)" />
   </xsl:call-template>

   <xsl:choose>
	<xsl:when test="@state = 1">
	    <xsl:text>CLOSED</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 2">
	    <xsl:text>LISTENING</xsl:text>
	</xsl:when>

	<xsl:when test="@state = 3">
	    <xsl:text>SYN_SENT</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 4">
	    <xsl:text>SYN_RECEIVED</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 5">
	    <xsl:text>ESTABLISHED</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 6">
	    <xsl:text>FIN_WAIT</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 7">
	    <xsl:text>FIN_WAIT2</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 8">
	    <xsl:text>CLOSE_WAIT</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 9">
	    <xsl:text>CLOSING</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 10">
	    <xsl:text>LAST_ACK</xsl:text>
	</xsl:when>
	<xsl:when test="@state = 11">
	    <xsl:text>TIME_WAIT</xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>???</xsl:text>
	</xsl:otherwise>
    </xsl:choose>

   </xsl:if>
  
   <xsl:call-template name="PrintReturn" />
  </xsl:template>

</xsl:transform>
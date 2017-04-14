<?xml version='1.0' ?>
<xsl:transform xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='1.0'>
 <xsl:import href='StandardTransforms.xsl'/>
 <xsl:output method='text'/>

 <xsl:template match="ExecCmd">
  <xsl:text>Running Command:  </xsl:text>
  <xsl:value-of select="." />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Ping">
  <xsl:text>Ping recieved from </xsl:text>
  <xsl:value-of select="@from"/>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="TCPport">
  <xsl:text>Listening on TCP Port:  </xsl:text>
  <xsl:value-of select="." />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>
 
 <xsl:template match="Connection">
	<xsl:text>New connection from </xsl:text>
	<xsl:value-of select="@ip"/>
	<xsl:text>:</xsl:text>
	<xsl:value-of select="@srcPort"/>
	<xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="LostConnection">
	<xsl:text>Lost connection from </xsl:text>
	<xsl:value-of select="@ip"/>
	<xsl:text>:</xsl:text>
	<xsl:value-of select="@srcPort"/>
	<xsl:call-template name="PrintReturn" />
 </xsl:template>
 
</xsl:transform>



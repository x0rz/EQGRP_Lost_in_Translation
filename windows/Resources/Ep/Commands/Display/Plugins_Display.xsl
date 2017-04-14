<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Plugins">
The following plugins are currently loaded LOCALLY:
   ID   COUNT  TYPE   VERSION     PLUGINNAME
----------------------------------------------------------------------
<xsl:apply-templates select="Plugin"/>
</xsl:template>

  <xsl:template match="RemotePlugins">
The following plugins are currently loaded REMOTELY:
   ID   COUNT   TYPE  AUTO_LOAD       PLUGINNAME
----------------------------------------------------------------------
<xsl:apply-templates select="RemotePlugin"/>
</xsl:template>

    <xsl:template match="Plugin">
	<xsl:text> </xsl:text>
	<xsl:value-of select="Id"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

	<xsl:value-of select="LoadCount"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="3"/>
	</xsl:call-template>

        <xsl:choose>
          <xsl:when test="@type = 'core'">
            <xsl:text> CORE </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>NORMAL</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="3"/>
	</xsl:call-template>

	<xsl:value-of select="Version/Plugin/@major"/>.<xsl:value-of select="Version/Plugin/@minor"/>.<xsl:value-of select="Version/Plugin/@build"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

        <xsl:value-of select="File"/>

	<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="RemotePlugin">
	<xsl:text> </xsl:text>
	<xsl:value-of select="Id"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

	<xsl:value-of select="LoadCount"/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

        <xsl:choose>
          <xsl:when test="@type = 'core'">
            <xsl:text> CORE</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>NORMAL</xsl:text>
          </xsl:otherwise>
        </xsl:choose>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="3"/>
	</xsl:call-template>

	<xsl:choose>
		<xsl:when test="AutoloadedBy = 0">
			<xsl:call-template name="Whitespace">
	    			<xsl:with-param name="i" select="5"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="AutoloadedBy"/>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="4"/>
	</xsl:call-template>

        <xsl:value-of select="File"/>

	<xsl:text>
</xsl:text>
    </xsl:template>

</xsl:transform>
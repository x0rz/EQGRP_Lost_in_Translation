<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>
  <xsl:preserve-space elements="*"/>

    <xsl:template match="BuiltIn">

Built-In Commands:
<xsl:apply-templates select="Cmd"/>
    </xsl:template>

    <xsl:template match="Plugins">

Plugin Commands:
<xsl:apply-templates select="Cmd"/>

- Loaded plugin commands have a '*' preceeding the command name

  For additional information try: &lt;command&gt; ?
</xsl:template>

    <xsl:template match="Prefixes">
Command Prefixes:
<xsl:apply-templates select="Prefix"/>
    </xsl:template>

    <xsl:template match="Cmd">
	<xsl:if test="((position()-1) != 0) and ((position()-1) mod 3 = 0)"><xsl:text>
</xsl:text>
	</xsl:if>

	<xsl:choose>

	    <xsl:when test="@loaded = 'yes'">
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="3" /> 
	        </xsl:call-template> * </xsl:when>

	    <xsl:otherwise>
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="6" /> 
	        </xsl:call-template>
	    </xsl:otherwise>

	</xsl:choose>

	<xsl:value-of select="."/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="20 - string-length(.)" /> 
	</xsl:call-template>


    </xsl:template>

    <xsl:template match="Prefix">
	<xsl:if test="((position()-1) != 0) and ((position()-1) mod 3 = 0)"><xsl:text>
</xsl:text>
	</xsl:if>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="6" /> 
        </xsl:call-template>

	<xsl:value-of select="."/>

	<xsl:call-template name="Whitespace">
	    <xsl:with-param name="i" select="20 - string-length(.)" /> 
	</xsl:call-template>


    </xsl:template>

</xsl:transform>
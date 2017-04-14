<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Directory">

    <xsl:call-template name="PrintDashes">
	<xsl:with-param name="path" select="@path"/>
	<xsl:with-param name="dashes" select="0"/>
    </xsl:call-template>

    <xsl:if test="@denied = 'true'">
	<xsl:text> (DENIED)</xsl:text>
    </xsl:if>
    <xsl:call-template name="PrintReturn"/>

  </xsl:template>

  <xsl:template match="Success">
	<xsl:text>Tree listing complete&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template name="PrintDashes">
	<xsl:param name="path"/>
	<xsl:param name="dashes"/>
	<xsl:variable name="str" select="substring-after($path, '\')"/>
	<xsl:choose>
	    <xsl:when test="string-length($str) > 0">
		<xsl:if test="$dashes > 0">
	            <xsl:text>|   </xsl:text>
		</xsl:if>

		<xsl:call-template name="PrintDashes">
		    <xsl:with-param name="path" select="$str"/>
		    <xsl:with-param name="dashes" select="number($dashes)+1"/>
		</xsl:call-template>
	    </xsl:when>
	    <xsl:otherwise>
		<xsl:choose>
		    <xsl:when test="$dashes > 0">
			<xsl:text>+---</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
			<xsl:call-template name="PrintReturn"/>
		    </xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$path"/>
	    </xsl:otherwise>
	</xsl:choose>
  </xsl:template>

</xsl:transform>
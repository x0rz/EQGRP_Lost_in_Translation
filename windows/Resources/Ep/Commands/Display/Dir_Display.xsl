<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Directory">
Directory : <xsl:value-of select="@path"/>

<xsl:text>&#x0D;&#x0A;&#x0D;&#x0A;</xsl:text>

<xsl:choose>
   <xsl:when test="@denied = 'true'">
	<xsl:text>    ACCESS_DENIED</xsl:text>
   </xsl:when>
   <xsl:otherwise>
	<xsl:apply-templates select="File"/>
   </xsl:otherwise>
</xsl:choose>

<xsl:text>&#x0D;&#x0A;</xsl:text>

</xsl:template>

    <xsl:template match="File">
	<xsl:if test="FileTime/@type = 'modified'">
	    <xsl:value-of select="substring-before(FileTime, 'T')"/>

	    <xsl:text> </xsl:text>

	    <xsl:value-of select="substring-after(FileTime, 'T')"/>

	    <xsl:text> </xsl:text>
	</xsl:if>

	<xsl:choose>
	    <xsl:when test="FileAttributeArchive"><xsl:text>A</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeCompressed"><xsl:text>C</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeEncrypted"><xsl:text>E</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeHidden"><xsl:text>H</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeOffline"><xsl:text>O</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeReadonly"><xsl:text>R</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeSystem"><xsl:text>S</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	    <xsl:when test="FileAttributeTemporary"><xsl:text>T</xsl:text></xsl:when>
	    <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
	</xsl:choose>

	<xsl:choose>
	    <xsl:when test="FileAttributeDirectory">
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="5"/>
		</xsl:call-template>
		<xsl:text>&lt;DIR&gt;</xsl:text>
	    </xsl:when>
	    
	    <xsl:otherwise>
		<xsl:call-template name="Whitespace">
		    <xsl:with-param name="i" select="10 - string-length(@size)"/>
		</xsl:call-template>
		<xsl:value-of select="@size"/>
	    </xsl:otherwise>
	</xsl:choose>

	<xsl:text> </xsl:text>

	<xsl:call-template name="Whitespace">
    	    <xsl:with-param name="i" select="12 - string-length(@short)"/>
	</xsl:call-template>

	<xsl:value-of select="@short"/>

	<xsl:text> </xsl:text>

	<xsl:value-of select="@name"/>

	<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="Success">
	<xsl:text>Directory listing complete&#x0D;&#x0A;</xsl:text>
    </xsl:template>

</xsl:transform>
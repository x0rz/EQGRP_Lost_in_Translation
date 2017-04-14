<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>
	
	<xsl:template match="Drives">
		<xsl:apply-templates select="Drive"/>
	</xsl:template>
	
	<xsl:template match="Drive">
		
		<xsl:variable name="used" select="@total - @available"/>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>----------------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				
				<xsl:text> File System : </xsl:text>
				<xsl:value-of select="@path" />
				<xsl:call-template name="PrintReturn"/>
				
				<xsl:text>    Total KB : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="@total div 1024"/>
					<xsl:with-param name="space" select="0"/>
				</xsl:call-template>
				<xsl:call-template name="PrintReturn"/>
				
				<xsl:text>     Used KB : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="$used div 1024"/>
					<xsl:with-param name="space" select="0"/>
				</xsl:call-template>
				<xsl:call-template name="PrintReturn"/>

				<xsl:text>Available KB : </xsl:text>
				<xsl:call-template name="PrintNumberWithCommas">
					<xsl:with-param name="number" select="@available div 1024"/>
					<xsl:with-param name="space" select="5"/>
				</xsl:call-template>
				<xsl:call-template name="PrintReturn"/>

				<xsl:text>       Usage : </xsl:text>
				<xsl:value-of select="floor(($used div @total) * 100)"/>
				<xsl:text> %</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Warning'"/>
			<xsl:with-param name="text">
  				<xsl:if test="@free &lt; (40 * 1024 * 1024)">
   					<xsl:text> (Diskspace is low on this drive)</xsl:text>
  				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
 	</xsl:template>

</xsl:transform>

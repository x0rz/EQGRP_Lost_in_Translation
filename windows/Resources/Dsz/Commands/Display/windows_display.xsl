<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="WindowStations">
		<xsl:apply-templates select="WindowStation"/>
	</xsl:template>
	<xsl:template match="WindowStation">
		<xsl:text>------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    Name : </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="@status">
			<xsl:text>  Status : </xsl:text>
			<xsl:value-of select="@status"/>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:text>   Flags :</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="WindowStationFlag_Visible">
			<xsl:text>           VISIBLE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		<xsl:text>Desktops : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Desktop"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="Desktop">
		<xsl:text>           </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="ScreenShot">
		<xsl:text>Screenshot written to:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="@subdir"/>
		<xsl:text>/</xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="Windows">
		<xsl:apply-templates select="Window"/>
	</xsl:template>
	<xsl:template match="Window">
		<xsl:if test="(count(WindowIsVisible) &gt; 0) or (string-length(@title) &gt; 0)">	
			<xsl:text>------------------------------------------------------------------</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			
			<xsl:text>    Name : </xsl:text>
			<xsl:value-of select="@title"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>   Value : </xsl:text>
			<xsl:value-of select="@hWnd"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text> Process : </xsl:text>
			<xsl:value-of select="@pid"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>  Coords : (</xsl:text>
			<xsl:value-of select="@x"/>
			<xsl:text>, </xsl:text>
			<xsl:value-of select="@y"/>
			<xsl:text>)</xsl:text>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>   Width : </xsl:text>
			<xsl:value-of select="@width"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>  Height : </xsl:text>
			<xsl:value-of select="@height"/>
			<xsl:call-template name="PrintReturn"/>
			<xsl:text>   Flags :</xsl:text>
			<xsl:if test="WindowIsVisible">
				<xsl:text> VISIBLE</xsl:text>
			</xsl:if>
			<xsl:if test="WindowIsMinimized">
				<xsl:text> MINIMIZED</xsl:text>
			</xsl:if>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="Buttons">
		<xsl:apply-templates select="Button"/>
	</xsl:template>
	<xsl:template match="Button">
		<xsl:text>------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Name : </xsl:text>
		<xsl:value-of select="."/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>      Id : </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text> Enabled : </xsl:text>
		<xsl:value-of select="@enabled"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
</xsl:transform>
<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="CtrlC">
    **** Ctrl-C was used ****
</xsl:template>

  <xsl:template match="Background">
     <xsl:text>Command </xsl:text>
     <xsl:value-of select="@request" />
     <xsl:text> moved to the background</xsl:text>
     <xsl:call-template name="PrintReturn" />
  </xsl:template>

  
  <xsl:template match="Echo">- <xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Input">Input : <xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Line"><xsl:value-of select="."/><xsl:call-template name="Return"/></xsl:template>
	
  <xsl:template match="No">NO<xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Pause">
	<xsl:choose>
	    <xsl:when test="@script">
%%% Script '<xsl:value-of select="@script"/>' has been paused <xsl:if test=".!=''">(<xsl:value-of select="."/>)</xsl:if> %%%

<xsl:if test="@continue='yes'">Continue? ([Yes]/Pause/Quit): </xsl:if></xsl:when>

	    <xsl:otherwise>PAUSE<xsl:call-template name="Return"/></xsl:otherwise>
	</xsl:choose>
  </xsl:template>

  <xsl:template match="Prompt">
	<xsl:choose>
	    <!-- prompt for an EP command -->
	    <xsl:when test="@type='cmd'">
@@@ Do you want to run the following command? @@@
        <xsl:value-of select="."/>

Run? (Yes/No/Pause/Quit): </xsl:when>
		
	    <!-- prompt with question -->
	    <xsl:when test="@type='question'">
<xsl:value-of select="."/> : ([Yes]/No/Pause/Quit): </xsl:when>
	
	    <!-- prompt for input -->
	    <xsl:otherwise>
<xsl:value-of select="."/> : </xsl:otherwise>
	</xsl:choose>
  </xsl:template>

  <xsl:template match="Quit">QUIT<xsl:call-template name="Return"/></xsl:template>

  <xsl:template match="Resume">
    ### Resuming '<xsl:value-of select="@script"/>' ###
</xsl:template>

  <xsl:template match="RunningCmd">Running EP command '<xsl:value-of select="."/>'
</xsl:template>
	
  <xsl:template match="Skip">
        *** Skipping Command ***

</xsl:template>
	
  <xsl:template match="Yes">YES<xsl:call-template name="Return"/></xsl:template>

  <!-- ignore elements -->
  <xsl:template match="SetEnv"/>
  <xsl:template match="Storage"/>
  <xsl:template match="Warning"/>

  <!-- functions -->
  <xsl:template name="Return"><xsl:text>
</xsl:text></xsl:template>

</xsl:transform>
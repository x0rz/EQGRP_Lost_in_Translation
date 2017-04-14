<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Events">
  <xsl:text> Rec #      Type         Date      Time     EvtID    Computer     Source</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>-------------------------------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:apply-templates select="Event" />
 </xsl:template>

 <xsl:template match="Event">
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="5 - string-length(@recordNumber)" />
  </xsl:call-template>
  <xsl:value-of select="@recordNumber" />
  <xsl:text>: </xsl:text>
  <xsl:value-of select="@eventType" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="16 - string-length(@eventType)" />
  </xsl:call-template>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="WriteTime" />
  </xsl:call-template>
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="6 - string-length(@code)" />
  </xsl:call-template>
  <xsl:value-of select="@code" />
  <xsl:text> </xsl:text>

  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="13 - string-length(@computer)" />
  </xsl:call-template>
  <xsl:value-of select="@computer" />

  <xsl:text>   </xsl:text>
  <xsl:value-of select="@source" />

  <xsl:call-template name="PrintReturn" />

  <!-- if we're only looking at a few events, print extra info -->
  <xsl:if test="30 > count(../Event)">
  	<xsl:text>&#09;Sid : </xsl:text>
	<xsl:call-template name="PrintReturn"/>	
	<xsl:text>&#09;    </xsl:text>
	<xsl:value-of select="@sid"/>
	<xsl:call-template name="PrintReturn"/>

	<xsl:if test="String">
	   <xsl:call-template name="PrintReturn"/>
	   <xsl:text>&#09;Strings :</xsl:text>
	   <xsl:call-template name="PrintReturn" />
	   <xsl:apply-templates select="String" />
	</xsl:if>
	<xsl:call-template name="PrintReturn" />
  </xsl:if>
 </xsl:template>

 <xsl:template match="String">
  <xsl:text>&#09;    </xsl:text>
  <xsl:value-of select="." />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>
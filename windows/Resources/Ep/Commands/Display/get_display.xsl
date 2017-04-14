<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="FileStart">
  <xsl:text>Receiving file:</xsl:text>
  <xsl:call-template name="PrintReturn"/>
  <xsl:text>&#x09;</xsl:text>
  <xsl:value-of select="@implantName"/>
  <xsl:call-template name="PrintReturn"/>
  <xsl:text>&#x09;Size : </xsl:text>
  <xsl:value-of select="@size"/>
  <xsl:text> bytes</xsl:text>
  <xsl:call-template name="PrintReturn"/>
 </xsl:template>

 <xsl:template match="LocalGetDirectory" />

 <xsl:template match="FileStop">
  <xsl:if test="@status = 'SUCCESS'">
    <xsl:text>&#x09;File get operation succeeded</xsl:text>
    <xsl:call-template name="PrintReturn"/>
  </xsl:if>
  <xsl:text>&#x09;Stored: </xsl:text>
  <xsl:value-of select="@size"/>
  <xsl:text> (</xsl:text>
  <xsl:value-of select="@status"/>
  <xsl:text>)&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x09;Stored to : </xsl:text>
  <xsl:value-of select="@localName"/>
  <xsl:call-template name="PrintReturn"/>
 </xsl:template>

 <xsl:template match="Conclusion">
  <xsl:call-template name="PrintReturn"/>
  <xsl:call-template name="PrintReturn"/>
  <xsl:value-of select="@successFiles" />
  <xsl:text> Files retrieved.&#x0D;&#x0A;</xsl:text>
  <xsl:value-of select="@partialFiles" />
  <xsl:text> Partial Files retrieved.&#x0D;&#x0A;</xsl:text>
  <xsl:value-of select="@failedFiles" />
  <xsl:text> Files transfers failed&#x0D;&#x0A;</xsl:text>
  <xsl:call-template name="PrintReturn"/>
  <xsl:text>Total bytes written </xsl:text>
  <xsl:value-of select="@bytesTransfered" />
  <xsl:call-template name="PrintReturn"/>
 </xsl:template>

</xsl:transform>
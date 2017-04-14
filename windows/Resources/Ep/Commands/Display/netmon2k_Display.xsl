<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Netmon2k">
  <xsl:text>Update:&#x0D;&#x0A;</xsl:text>
  <xsl:apply-templates select="Netmon"/>
  <xsl:apply-templates select="Mcsvc"/>
  <xsl:apply-templates select="NetmonStart"/>
  <xsl:apply-templates select="NetmonStop"/>
  <xsl:apply-templates select="NetmonCapStart"/>
  <xsl:apply-templates select="NetmonCapStop"/>
  <xsl:apply-templates select="McsvcStart"/>
  <xsl:apply-templates select="McsvcStop"/>
  <xsl:apply-templates select="McsvcCapStart"/>
  <xsl:apply-templates select="McsvcCapStop"/>
 </xsl:template>

 <xsl:template match="Netmon">
  <xsl:text>Netmon:</xsl:text>
  <xsl:choose>
   <xsl:when test="@running = 1">
    <xsl:if test="@running = 1">
     <xsl:text>Running</xsl:text>
    </xsl:if>
    <xsl:if test="@capturing = 1">
     <xsl:text> And Capturing</xsl:text>
    </xsl:if>
    <xsl:if test="@kerneltime > 0">
     <xsl:text>; Kernel Time:</xsl:text>
     <xsl:value-of select="@kerneltime" />
    </xsl:if>
   </xsl:when>
   <xsl:when test="@running = 0">
    <xsl:text>Not running</xsl:text>
   </xsl:when>   
  </xsl:choose>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="Mcsvc">
  <xsl:text>MCSvc:</xsl:text>
  <xsl:choose>
   <xsl:when test="@running = 1">
    <xsl:if test="@running = 1">
     <xsl:text>Running</xsl:text>
    </xsl:if>
    <xsl:if test="@capturing = 1">
     <xsl:text> And Capturing</xsl:text>
    </xsl:if>
    <xsl:if test="@kerneltime > 0">
     <xsl:text>; Kernel Time:</xsl:text>
     <xsl:value-of select="@kerneltime" />
    </xsl:if>
   </xsl:when>
   <xsl:when test="@running = 0">
    <xsl:text>Not running</xsl:text>
   </xsl:when>   
  </xsl:choose>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="NetmonStart">
  <xsl:text>Event:  Netmon is now running.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="NetmonStop">
  <xsl:text>Event:  Netmon has stopped.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="NetmonCapStart">
  <xsl:text>Event:  Netmon appears to have started capturing.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="NetmonCapStop">
  <xsl:text>Event:  Netmon appears to have stopped capturing.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="McsvcStart">
  <xsl:text>Event:  MSCvc is now running.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="McsvcStop">
  <xsl:text>Event:  MSCvc has stopped.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="McsvcCapStart">
  <xsl:text>Event:  MSCvc appears to have started capturing.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="McsvcCapStop">
  <xsl:text>Event:  MSCvc appears to have stopped capturing.&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="Success">
  <xsl:text>&#x0D;&#x0A;Finished&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="CtrlC">
  <xsl:text>**** Ctrl-C was used ****&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>
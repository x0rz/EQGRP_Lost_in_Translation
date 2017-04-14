<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Memory">
  <xsl:text>Memory&#x0D;&#x0A;</xsl:text>
  <xsl:text>  Physical Load: </xsl:text>
  <xsl:value-of select="@memPhysLoad" />
  <xsl:text>%&#x0D;&#x0A;</xsl:text>


  <xsl:variable name="TotalMem" select="format-number(Physical/@total + Page/@total + Virtual/@total, '#,###,###,###')" />
  <xsl:variable name="TotalMemMB" select="format-number((Physical/@total + Page/@total + Virtual/@total) div 1000000, '#,###.##')" />

  <xsl:text>  Total Memory:                </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($TotalMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalMem" /> 
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($TotalMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalMemMB" />
  <xsl:text> MB</xsl:text> 
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="TotalPhysMem" select="format-number(Physical/@total, '#,###,###,###')" />
  <xsl:variable name="TotalPhysMemMB" select="format-number(Physical/@total div 1000000, '#,###.##')" />


  <xsl:text>    Physical Memory Total:     </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($TotalPhysMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalPhysMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($TotalPhysMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalPhysMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="TotalPageMem" select="format-number(Page/@total, '#,###,###,###')" />
  <xsl:variable name="TotalPageMemMB" select="format-number(Page/@total div 1000000, '#,###.##')" />


  <xsl:text>    PageFile Total:            </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($TotalPageMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalPageMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($TotalPageMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalPageMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="TotalVirtMem" select="format-number(Virtual/@total, '#,###,###,###')" />
  <xsl:variable name="TotalVirtMemMB" select="format-number(Virtual/@total div 1000000, '#,###.##')" />


  <xsl:text>    Virtual Memory Total:      </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($TotalVirtMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalVirtMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($TotalVirtMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$TotalVirtMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="AvailMem" select="format-number(Physical/@available + Page/@available + Virtual/@available, '#,###,###,###')" />
  <xsl:variable name="AvailMemMB" select="format-number((Physical/@available + Page/@available + Virtual/@available) div 1000000, '#,###.##')" />


  <xsl:text>  Total Memory Available:      </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($AvailMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($AvailMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="AvailPhysMem" select="format-number(Physical/@available, '#,###,###,###')" />
  <xsl:variable name="AvailPhysMemMB" select="format-number(Physical/@available div 1000000, '#,###.##')" />



  <xsl:text>    Physical Memory Available: </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($AvailPhysMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailPhysMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($AvailPhysMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailPhysMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="AvailPageMem" select="format-number(Page/@available, '#,###,###,###')" />
  <xsl:variable name="AvailPageMemMB" select="format-number(Page/@available div 1000000, '#,###.##')" />


  <xsl:text>    PageFile Available:        </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($AvailPageMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailPageMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($AvailPageMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailPageMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:variable name="AvailVirtMem" select="format-number(Virtual/@available, '#,###,###,###')" />
  <xsl:variable name="AvailVirtMemMB" select="format-number(Virtual/@available div 1000000, '#,###.##')" />


  <xsl:text>    Virtual Memory Available:  </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="15 - string-length($AvailVirtMem)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailVirtMem" />
  <xsl:text> Bytes </xsl:text>
   <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="10 - string-length($AvailVirtMemMB)" /> 
   </xsl:call-template>
  <xsl:value-of select="$AvailVirtMemMB" />
  <xsl:text> MB</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:if test="(Physical/@available div 1000000) &lt; 10 or (Physical/@total div 1000000) &lt; 10 or (Page/@available div 1000000) &lt; 10 or (Page/@total div 1000000) &lt; 10 or (Virtual/@available div 1000000) &lt; 10 or (Virtual/@total div 1000000) &lt; 10">
   <xsl:text>&#x0D;&#x0A;</xsl:text>
   <xsl:text>**** MEMORY ON THE TARGET IS VERY LOW ****</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

 </xsl:template>

</xsl:transform>
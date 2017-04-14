<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="FileAttribs">

  <xsl:text>Attributes (EX): (</xsl:text>
  <xsl:value-of select="@attributeMask" />
  <xsl:text>)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  
  <xsl:if test="FILE_ATTRIBUTE_ARCHIVE">            <xsl:text>        FILE_ATTRIBUTE_ARCHIVE            </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_COMPRESSED">         <xsl:text>        FILE_ATTRIBUTE_COMPRESSED         </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_DIRECTORY">          <xsl:text>        FILE_ATTRIBUTE_DIRECTORY          </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_ENCRYPTED">          <xsl:text>        FILE_ATTRIBUTE_ENCRYPTED          </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_HIDDEN">             <xsl:text>        FILE_ATTRIBUTE_HIDDEN             </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_NORMAL">             <xsl:text>        FILE_ATTRIBUTE_NORMAL             </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_OFFLINE">            <xsl:text>        FILE_ATTRIBUTE_OFFLINE            </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_READONLY">           <xsl:text>        FILE_ATTRIBUTE_READONLY           </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_REPARSE_POINT">      <xsl:text>        FILE_ATTRIBUTE_REPARSE_POINT      </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_SPARSE_FILE">        <xsl:text>        FILE_ATTRIBUTE_SPARSE_FILE        </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_SYSTEM">             <xsl:text>        FILE_ATTRIBUTE_SYSTEM             </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_TEMPORARY">          <xsl:text>        FILE_ATTRIBUTE_TEMPORARY          </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_ATTRIBUTE_NOT_CONTENT_INDEXED"><xsl:text>        FILE_ATTRIBUTE_NOT_CONTENT_INDEXED</xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>

  <xsl:text> Created Time : </xsl:text>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="@createdTime" />
  </xsl:call-template>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Accessed Time : </xsl:text>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="@accessedTime" />
  </xsl:call-template>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Modified Time : </xsl:text>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="@modifiedTime" />
  </xsl:call-template>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>
</xsl:transform>
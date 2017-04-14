<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>
 <xsl:template match="LotusNotesParser">
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 <xsl:text>Mail Messages Displayed Below: </xsl:text>
 <xsl:value-of select="@msgsProcessed"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>**********************************************************</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text> 
  <xsl:apply-templates select="Email"/>
  </xsl:template>
  <xsl:template match="Email">

  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>Message ID</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('Message ID')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="MsgID"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>To</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('To')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="To"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>From</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('From')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="From"/> 
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>CC</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('CC')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="CC"/> 
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>BCC</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('BCC')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="Bcc"/> 
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Subject</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('Subject')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="Subject"/> 
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Composed Date</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('Composed Date')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="ComposedDate"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Posted Date</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('Posted Date')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="PostedDate"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Delivered Date</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('Delivered Date')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="DeliveredDate"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:if test="@bodyReq = 'true'">
    <xsl:text>Message Body</xsl:text>
    <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="14 - string-length('Message Body')" /> 
    </xsl:call-template>
    <xsl:text>: </xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:value-of select="Body"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:text># Attachments</xsl:text>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="14 - string-length('# Attachments')" /> 
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="@numAtt"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:if test="@numAtt > 0">
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:text>Size</xsl:text>
    <xsl:call-template name="Whitespace">
    <xsl:with-param name="i" select="8" /> 
    </xsl:call-template>
    <xsl:text>Name</xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>    
  </xsl:if>

  <xsl:apply-templates select="Attachment"/>  

  <xsl:text>---------------------------------------------------------</xsl:text>

  <xsl:if test="@attVal = 'true'">
    <xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:text>The contents of the Attachments listed above are stored in the XML file.</xsl:text>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="Attachment">

  <xsl:value-of select="@attSize"/>
  <xsl:call-template name="Whitespace">
  <xsl:with-param name="i" select="12 - string-length(@attSize)"/> 
  </xsl:call-template>
  <xsl:value-of select="@attName"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
<!-- Deliberately not transforming attachment contents for display on console -->
 </xsl:template>

 <xsl:template match="Success" />
</xsl:transform>



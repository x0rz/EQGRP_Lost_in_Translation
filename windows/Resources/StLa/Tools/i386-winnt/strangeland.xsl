<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <!-- This document as an XML/XSTL document and is therefore, by definition Human Readable -->
  <xsl:output method="html"/>

  <xsl:template match="/">
    <html>
      <body bgcolor="#FFFFFF">
        <center><h2>Strangeland KeyLog</h2></center>
        <table border="1">
          
          <tr><td>Labels are <b>bold</b></td></tr>
          <tr><td>Virtual keys (such as caps-lock) are <i>italics</i></td></tr>
          <tr><td>Clipboard events (not necessarily paste) are <font color="blue">blue</font></td></tr>
          <tr><td>Keystrokes are normal.</td></tr>
          <tr><td>Timestamps are in GMT</td></tr>
        </table>
        <P></P>
        *Note: Not call paste commands can be captured, so the keylogger aggresively captures clipboard events.  Not all clipboard events are paste commands.  This is very application-specific, so the operator will have to disinguish.

        <xsl:call-template name="sessionIterator">
          <xsl:with-param name="sessionID" select="0"/>
        </xsl:call-template>
      </body>
    </html>
  </xsl:template>

 
<xsl:template match="text()">
  <xsl:value-of select="normalize-space()"/>
</xsl:template>


<xsl:template match="Log" name="showSessionLog">
  <xsl:param name="sessionID"/>
  <xsl:if test="count(//KeyLogger_Data/Log[SessionID=$sessionID])>0">
  <CENTER><h3>------- Session <xsl:value-of select="$sessionID"/> -------</h3></CENTER>    
  </xsl:if>

  <xsl:for-each select="//KeyLogger_Data/Log"> 
    <xsl:if test="SessionID=$sessionID">
      <xsl:if test="position()=0">
        <CENTER><h3>--- Session <xsl:value-of select="$sessionID"/> ---</h3></CENTER>
      </xsl:if>
      <xsl:if test="''!=UserName">
        <b>*** Username *** :</b> <xsl:value-of select="UserName"/><p/>
      </xsl:if>        
    <b><xsl:value-of select="GMTTime"/>: <xsl:value-of select="ProcessName"/>(<xsl:value-of select="ProcessID"/>):"<xsl:value-of select="WindowName"/>"</b>
    <p/>
    <xsl:for-each select="Keys">
      <xsl:choose>
        <xsl:when test="@Source ='virtual'">
          <pre style="display:inline"><i><xsl:value-of select="."/></i></pre>
        </xsl:when>
        <xsl:when test="@Source ='clipboard'">
          <pre style="display:inline"><font color="blue"><xsl:value-of select="."/></font></pre>
        </xsl:when>
        <xsl:when test="@Source='normal'">
          <pre style="display:inline"><xsl:value-of select="."/></pre>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <p></p>
    <p></p>
    </xsl:if>
  </xsl:for-each>
  <P/>
</xsl:template>


<xsl:template name="sessionIterator">
  <xsl:param name="sessionID" select="1"/>
  <xsl:call-template name ="showSessionLog">
    <xsl:with-param name="sessionID" select="$sessionID"/>        
  </xsl:call-template>
  <xsl:if test="$sessionID &lt; 100">
    <xsl:call-template name="sessionIterator">
      <xsl:with-param name="sessionID" select="$sessionID +1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>





</xsl:stylesheet>

<!-- Stylus Studio meta-information - (c) 2004-2006. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="bob.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->
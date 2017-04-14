<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="FileAttribs"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="FileAttribs">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">Size</xsl:attribute>
      <xsl:choose>
       <xsl:when test="@size &gt; 4294967296">
        <xsl:attribute name="value"><xsl:value-of select="@size"/></xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">4294967296</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="value"><xsl:value-of select="@size"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">CreatedDate</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDY">
        <xsl:with-param name="i" select="@createdTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">AccessedDate</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDY">
        <xsl:with-param name="i" select="@accessedTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ModifiedDate</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDY">
        <xsl:with-param name="i" select="@modifiedTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">CreatedTime</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeHMS">
        <xsl:with-param name="i" select="@createdTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">AccessedTime</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeHMS">
        <xsl:with-param name="i" select="@accessedTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">ModifiedTime</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeHMS">
        <xsl:with-param name="i" select="@modifiedTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_ARCHIVE</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_ARCHIVE">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_COMPRESSED</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_COMPRESSED">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_DIRECTORY</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_DIRECTORY">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_ENCRYPTED</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_ENCRYPTED">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_HIDDEN</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_HIDDEN">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_NORMAL</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_NORMAL">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_OFFLINE</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_OFFLINE">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_READONLY</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_READONLY">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_REPARSE_POINT</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_REPARSE_POINT">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_SPARSE_FILE</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_SPARSE_FILE">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_SYSTEM</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_SYSTEM">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_TEMPORARY</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_TEMPORARY">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">false</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">FILE_ATTRIBUTE_NOT_CONTENT_INDEXED</xsl:attribute>
      <xsl:choose>
       <xsl:when test="FILE_ATTRIBUTE_NOT_CONTENT_INDEXED">
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:when>
       <xsl:otherwise>
        <xsl:attribute name="value">true</xsl:attribute>
       </xsl:otherwise>     
      </xsl:choose>
    </xsl:element>
  </xsl:template>



</xsl:transform>
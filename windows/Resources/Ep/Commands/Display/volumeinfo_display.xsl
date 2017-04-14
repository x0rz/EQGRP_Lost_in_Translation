<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="VolumeInfo">

  <xsl:text>         Volume Name : </xsl:text>
  <xsl:value-of select="VolumeName" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>       Serial Number : </xsl:text>
  <xsl:value-of select="SerialNumber" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Max Component Length : </xsl:text>
  <xsl:value-of select="@maximumComponentLength" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>    File system Name : </xsl:text>
  <xsl:value-of select="FileSystemName" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:apply-templates select="Flags" />

 </xsl:template>
 <xsl:template match="Flags">
  <xsl:text>File system Flags : </xsl:text>
  <xsl:value-of select="@value" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:if test="FS_CASE_IS_PRESERVED">        <xsl:text>        FS_CASE_IS_PRESERVED        </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FS_CASE_SENSITIVE">           <xsl:text>        FS_CASE_SENSITIVE           </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FS_UNICODE_STORED_ON_DISK">   <xsl:text>        FS_UNICODE_STORED_ON_DISK   </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FS_PERSISTENT_ACLS">          <xsl:text>        FS_PERSISTENT_ACLS          </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FS_FILE_COMPRESSION">         <xsl:text>        FS_FILE_COMPRESSION         </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FS_VOL_IS_COMPRESSED">        <xsl:text>        FS_VOL_IS_COMPRESSED        </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_NAMED_STREAMS">          <xsl:text>        FILE_NAMED_STREAMS          </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_SUPPORTS_ENCRYPTION">    <xsl:text>        FILE_SUPPORTS_ENCRYPTION    </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_SUPPORTS_OBJECT_IDS">    <xsl:text>        FILE_SUPPORTS_OBJECT_IDS    </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_SUPPORTS_REPARSE_POINTS"><xsl:text>        FILE_SUPPORTS_REPARSE_POINTS</xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_SUPPORTS_SPARSE_FILES">  <xsl:text>        FILE_SUPPORTS_SPARSE_FILES  </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
  <xsl:if test="FILE_VOLUME_QUOTAS">          <xsl:text>        FILE_VOLUME_QUOTAS          </xsl:text><xsl:text>&#x0D;&#x0A;</xsl:text></xsl:if>
 </xsl:template>
</xsl:transform>
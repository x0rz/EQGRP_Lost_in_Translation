<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Processes">
  <xsl:text>    PID        PARENT         CREATE TIME      TYPE    NAME</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>-------------------------------------------------------------------------------</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:apply-templates select="Process"/>
 </xsl:template>

 <xsl:template match="Process">
  <xsl:if test="not(@ignore) or (@ignore = '0')">
     <xsl:variable name="procdate"   select="substring-before(@procTime, 'T')" />
     <xsl:variable name="proctime"   select="substring-after (@procTime, 'T')" />

     <xsl:variable name="procyear"   select="substring-before($procdate, '-')"                       />
     <xsl:variable name="procmonth"  select="substring-before(substring-after($procdate, '-'), '-')" />
     <xsl:variable name="procday"    select="substring-after(substring-after($procdate, '-'), '-')"  />
     <xsl:variable name="prochour"   select="substring-before($proctime, ':')"                       />
     <xsl:variable name="procminute" select="substring-before(substring-after($proctime, ':'), ':')" />
     <xsl:variable name="procsecond" select="substring-after(substring-after($proctime, ':'), ':')"  />

     <xsl:variable name="kerntime"   select="substring-after (@kernTime, 'T')" />

     <xsl:variable name="kernhour"   select="substring-before($kerntime, ':')"                       />
     <xsl:variable name="kernminute" select="substring-before(substring-after($kerntime, ':'), ':')" />
     <xsl:variable name="kernsecond" select="substring-after(substring-after($kerntime, ':'), ':')"  />

     <xsl:variable name="usertime"   select="substring-after (@userTime, 'T')" />

     <xsl:variable name="userhour"   select="substring-before($usertime, ':')"                       />
     <xsl:variable name="userminute" select="substring-before(substring-after($usertime, ':'), ':')" />
     <xsl:variable name="usersecond" select="substring-after(substring-after($usertime, ':'), ':')"  />

    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="ceiling((12 - string-length(@id)) div 2)" /> 
    </xsl:call-template>
    <xsl:value-of select="@id" />
    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="floor((12 - string-length(@id)) div 2)" /> 
    </xsl:call-template>

    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="ceiling((12 - string-length(@parent)) div 2)" /> 
    </xsl:call-template>
    <xsl:value-of select="@parent" />
    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="floor((12 - string-length(@parent)) div 2)" /> 
    </xsl:call-template>

    <xsl:choose>
     <xsl:when test="@procTime">
      <xsl:variable name="createFormat"   select="concat(' ',
                                                format-number($procmonth,  '00'),   '/',
                                                format-number($procday,    '00'),   '/',
                                                format-number($procyear,   '0000'), ' ',
                                                format-number($prochour,   '00'),   ':',
                                                format-number($procminute, '00'),   ':',
                                                format-number($procsecond, '00'),   ' '
                                              )"/>
      <xsl:call-template name="Whitespace">
       <xsl:with-param name="i" select="23 - string-length($createFormat)" /> 
      </xsl:call-template>
    <xsl:value-of select="$createFormat" />
      </xsl:when>
      <xsl:otherwise>
      <xsl:variable name="createFormat"   select="concat(' ',
                                                format-number(0, '00'),   '/',
                                                format-number(0, '00'),   '/',
                                                format-number(0, '0000'), ' ',
                                                format-number(0, '00'),   ':',
                                                format-number(0, '00'),   ':',
                                                format-number(0, '00'),   ' '
                                              )"/>
      <xsl:call-template name="Whitespace">
       <xsl:with-param name="i" select="23 - string-length($createFormat)" /> 
      </xsl:call-template>
      <xsl:value-of select="$createFormat" />
      </xsl:otherwise>
     </xsl:choose>
   

    <xsl:choose>
        <xsl:when test="not(@started)">
		<xsl:text>  INIT </xsl:text>
	</xsl:when>
        <xsl:when test="@started = 'true'">
		<xsl:text> START </xsl:text>
	</xsl:when>
        <xsl:otherwise>
		<xsl:text>  STOP </xsl:text>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:text> </xsl:text>

    <xsl:call-template name="StripPath">
        <xsl:with-param name="path" select="."/>
      </xsl:call-template>

    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:if test="string-length(@comment) > 0">
	<xsl:text>&#x09;</xsl:text>
	<xsl:value-of select="@comment"/>
        <xsl:text>&#x0D;&#x0A;</xsl:text>
    </xsl:if>

  </xsl:if>
 </xsl:template>

<!-- Functions -->
  <xsl:template name="StripPath">
    <xsl:param name="path"/>
    <xsl:choose>
      <xsl:when test="contains($path, '\')">
        <xsl:call-template name="StripPath">
          <xsl:with-param name="path" select="substring-after($path, '\')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
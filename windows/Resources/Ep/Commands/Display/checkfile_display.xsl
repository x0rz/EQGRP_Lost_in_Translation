<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Checkfile">

  <xsl:text>------&gt;&#x09;</xsl:text>
  <xsl:value-of select="@file_name" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x09;File exists on the target system.</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:choose>
   <xsl:when test="@check_length = 1">
    <xsl:choose>
     <xsl:when test="@lengths_match = 1">
      <xsl:text>&#x09;Length of </xsl:text>
      <xsl:value-of select="@file_length" />
      <xsl:text> bytes agrees with what user specified.</xsl:text> 
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>&#x09;File's length of </xsl:text>
      <xsl:value-of select="@file_length" />
      <xsl:text> bytes does not agree with what</xsl:text>
      <xsl:text>&#x0D;&#x0A;</xsl:text>
      <xsl:text>&#x09;user specified. (</xsl:text>
      <xsl:value-of select="@user_specified_length" />
      <xsl:text> bytes)</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>&#x09;Length is </xsl:text>
    <xsl:value-of select="@file_length" />
    <xsl:text> bytes.&#x0D;&#x0A;</xsl:text> 
   </xsl:otherwise>
  </xsl:choose>

  <xsl:variable name="date_file"   select="substring-before(@last_save_dateTime, 'T')" />
  <xsl:variable name="time_file"   select="substring-after (@last_save_dateTime, 'T')" />

  <xsl:variable name="year_file"   select="substring-before($date_file, '-')"                       />
  <xsl:variable name="month_file"  select="substring-before(substring-after($date_file, '-'), '-')" />
  <xsl:variable name="day_file"    select="substring-after(substring-after($date_file, '-'), '-')"  />
  <xsl:variable name="hour_file"   select="substring-before($time_file, ':')"                       />
  <xsl:variable name="minute_file" select="substring-before(substring-after($time_file, ':'), ':')" />
  <xsl:variable name="second_file" select="substring-after(substring-after($time_file, ':'), ':')"  />

  <xsl:variable name="date_user"   select="substring-before(@user_specified_dateTime, 'T')" />
  <xsl:variable name="time_user"   select="substring-after (@user_specified_dateTime, 'T')" />

  <xsl:variable name="year_user"   select="substring-before($date_user, '-')"                       />
  <xsl:variable name="month_user"  select="substring-before(substring-after($date_user, '-'), '-')" />
  <xsl:variable name="day_user"    select="substring-after(substring-after($date_user, '-'), '-')"  />
  <xsl:variable name="hour_user"   select="substring-before($time_user, ':')"                       />
  <xsl:variable name="minute_user" select="substring-before(substring-after($time_user, ':'), ':')" />
  <xsl:variable name="second_user" select="substring-after(substring-after($time_user, ':'), ':')"  />
  
  <xsl:variable name="MDY_file"    select="concat($month_file, '/', $day_file, '/', $year_file)"    />
  <xsl:variable name="MDY_user"    select="concat($month_user, '/', $day_user, '/', $year_user)"    />

  <xsl:variable name="HM_file"     select="concat($hour_file, ':', $minute_file)"                   />
  <xsl:variable name="HM_user"     select="concat($hour_user, ':', $minute_user)"                   />
  

  <xsl:choose>
   <xsl:when test="@check_date = 1">
    <xsl:choose>
     <xsl:when test="@dates_match = 1">
      <xsl:text>&#x09;Date last written of </xsl:text>
      <xsl:value-of select="$MDY_file" />
      <xsl:text> agrees with what user specified.</xsl:text> 
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>&#x09;Date last written of </xsl:text>
      <xsl:value-of select="$MDY_file" />
      <xsl:text> does not agree with what the</xsl:text>
      <xsl:text>&#x0D;&#x0A;</xsl:text>
      <xsl:text>&#x09;user specified. (</xsl:text>
      <xsl:value-of select="$MDY_user" />
      <xsl:text>)</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>&#x09;Date last written was </xsl:text>
    <xsl:value-of select="$MDY_file" />
    <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
   <xsl:when test="@check_time = 1">
    <xsl:choose>
     <xsl:when test="@times_match = 1">
      <xsl:text>&#x09;Time last written of </xsl:text>
      <xsl:value-of select="$HM_file" />
      <xsl:text> agrees with what user specified.</xsl:text> 
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>&#x09;Time last written of </xsl:text>
      <xsl:value-of select="$HM_file" />
      <xsl:text> does not agree with what the</xsl:text>
      <xsl:text>&#x0D;&#x0A;</xsl:text>
      <xsl:text>&#x09;user specified. (</xsl:text>
      <xsl:value-of select="$HM_user" />
      <xsl:text>)</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>&#x09;Time last written was </xsl:text>
    <xsl:value-of select="$HM_file" />
    <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
   <xsl:when test="@check_checksum = 1">
    <xsl:choose>
     <xsl:when test="@checksum_match = 1">
      <xsl:text>&#x09;Checksum of </xsl:text>
      <xsl:value-of select="@checksum" />
      <xsl:text> agrees with what user specified.</xsl:text> 
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>&#x09;Checksum of </xsl:text>
      <xsl:value-of select="@checksum" />
      <xsl:text>&#x0D;&#x0A;</xsl:text>
      <xsl:text>&#x09;does not agree with what the user specified.</xsl:text>
      <xsl:text>&#x0D;&#x0A;</xsl:text>
      <xsl:text>&#x09;&#x09;</xsl:text>
      <xsl:value-of select="@user_specified_checksum" />
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:if test="@checksum != 0">
      <xsl:text>&#x09;Checksum of </xsl:text>
      <xsl:value-of select="@checksum" />
      <xsl:text>&#x0D;&#x0A;</xsl:text>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:transform>
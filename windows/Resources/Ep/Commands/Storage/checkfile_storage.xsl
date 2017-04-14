<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Checkfile"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Checkfile">

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

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">file_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@file_name"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">check_date</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@check_date"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">check_time</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@check_time"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">check_length</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@check_length"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">check_checksum</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@check_checksum"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">dates_match</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@dates_match"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">times_match</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@times_match"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">lengths_match</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@lengths_match"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">checksum_match</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@checksum_match"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_save_date</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="concat($month_file, '/', $day_file, '/', $year_file)"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user_specified_date</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="concat($month_user, '/', $day_user, '/', $year_user)"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">last_save_time</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="concat($hour_file, ':', $minute_file, ':', $second_file)"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user_specified_time</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="concat($hour_user, ':', $minute_user, ':', $second_user)"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">file_length</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@file_length"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">user_specified_length</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@user_specified_length"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">checksum</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@checksum"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user_specified_checksum</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@user_specified_checksum"/></xsl:attribute>
    </xsl:element>

  </xsl:template>

</xsl:transform>
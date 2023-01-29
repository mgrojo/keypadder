--  SPDX-License-Identifier: GPL-3.0-or-later
--  SPDX-FileCopyrightText:


with Ada.Text_IO; use Ada.Text_IO;

with AWS.Parameters;

with Config;   use Config;

package body Frontend is

   function Request_CB (Request : AWS.Status.Data) return AWS.Response.Data is
      URI : constant String := AWS.Status.URI (Request);
      Parms : AWS.Parameters.List;
   begin
      if URI = "/" then
         return AWS.Response.Build ("text/html", To_String (Main_Page_HTML));
      elsif URI = "/buttonpress" then
         Parms := AWS.Status.Parameters (Request);
         Put_Line ("Got request: <" & To_String (AWS.Parameters.Get (Parms, 1).Name) & ">");
         return AWS.Response.Build ("text/html", "<p>NYI");
      elsif URI = "/shutdown" then
         Shutting_Down := True;
         return AWS.Response.Build ("text/html", "<p>Shutting down...");
      else
         return AWS.Response.Build ("text/html", "<p>Unknown request");
      end if;
   end Request_CB;

   procedure Build_Main_Page is
   begin
      Append (Main_Page_HTML, "<html><head><style>" & ASCII.LF &
                        "body {background-color: darkgray; color: white;}"  & ASCII.LF &
                        ".kp-pad {align-content: stretch;}" &
                        ".kp-btn {font-size: 20mm; background-color: black; padding: 2mm; color: white;}"  & ASCII.LF &
                        "</style></head>" & ASCII.LF &
                        "<body>" & ASCII.LF);

      --  first the tab headers
      Append (Main_Page_HTML, "<div class=""kp-bar kp-black"">");
      for T in 1 .. Conf.Tabs_Count loop
         Append (Main_Page_HTML, "<button class=""kp-bar-item kp-button"" onclick=""openTab('" &
                                 Conf.Tabs (T).Label & "')"">" &
                                 Conf.Tabs (T).Label & "</button>" & ASCII.LF);
      end loop;
      Append (Main_Page_HTML, "</div>" & ASCII.LF);

      Append (Main_Page_HTML, "<form action=""/buttonpress"">" & ASCII.LF);
      --  now each tab
      for T in 1 .. Conf.Tabs_Count loop
         Append (Main_Page_HTML, "<div id=""" & Conf.Tabs (T).Label & """ class=""kp-pad""");
         if T > 1 then --  hide secondary Tabs
            Append (Main_Page_HTML, " style=""display:none""");
         end if;
         Append (Main_Page_HTML, ">" & ASCII.LF);

         --  the main content of each tab - i.e. the keys
         Append (Main_Page_HTML, "<div style=""margin: 0 auto; display: grid; gap: 1rem; align-content: stretch; height: 95vh;");
         Append (Main_Page_HTML, "grid-template-columns: repeat(" & Conf.Tabs (T).Columns'Image & ", 1fr);"">");
         for K in 1 .. Conf.Tabs (T).Keys_Count loop
            Append (Main_Page_HTML, "<input type=""submit"" class=""kp-btn""");
            if Conf.Tabs (T).Keys (K).Colspan > 1 then
               Append (Main_Page_HTML, " style=""grid-column: span" & Conf.Tabs (T).Keys (K).Colspan'Image & ";"" ");
            end if;
            if Conf.Tabs (T).Keys (K).Rowspan > 1 then
               Append (Main_Page_HTML, " style=""grid-row: span" & Conf.Tabs (T).Keys (K).Rowspan'Image & ";"" ");
            end if;
            Append (Main_Page_HTML, " name=""key_t" & T'Image (2 .. T'Image'Last) &
                                    "i" & K'Image (2 .. K'Image'Last) & """ value=""" & Conf.Tabs (T).Keys (K).Label & """>");
         end loop;
         Append (Main_Page_HTML, "</div></div>");
      end loop;

      --  javascript to change displayed tab
      Append (Main_Page_HTML, "<script> function openTab(tabName) {");
      Append (Main_Page_HTML, "var i; var x = document.getElementsByClassName('kp-pad');");
      Append (Main_Page_HTML, "for (i=0; i<x.length; i++) { x[i].style.display = 'none';}");
      Append (Main_Page_HTML, "document.getElementById(tabName).style.display = 'block'; } </script>");

      Append (Main_Page_HTML, "</form></body></html>");
   end Build_Main_Page;

end Frontend;
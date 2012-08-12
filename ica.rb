#!/usr/bin/env ruby
# encoding: utf-8
# AtomICA by Henrik Nyh <http://henrik.nyh.se>. See README.

require "cgi"
require "ostruct"

require "mechanize"
require "builder"

class AtomICA
  NAME = "AtomICA"
  VERSION = "1.1"
  SCHEMA_DATE = "2008-11-19"

  def initialize(pnr, pwd)
    @pnr = pnr.gsub(/\D/, '')  # Only keep digits.
    @pwd = pwd.gsub(/\D/, '')
  end

  def render
    atomize(scrape)
  end

  private

  def scrape
    items = []
    agent = Mechanize.new
    login_page = agent.get("https://mobil2.icabanken.se/")

    # Log in
    entry_page = login_page.form_with(action: 'login.aspx') do |f|
      f.pnr_phone = @pnr
      f.pwd_phone = @pwd
    end.click_button

    # Go to overview
    details_page = agent.click(entry_page.link_with(text: /versikt/))

    # Follow account links and scrape
    account_links = details_page.links_with(href: /account\.aspx/)
    account_links.each do |link|
      account_page = agent.click(link)

      header = account_page.at('div.main div b')
      account_name = header.children.first.to_s.sub(/,\s*$/, '')
      account_number = header.at('span').inner_text

      rows = account_page.search('.row')
      rows.each_with_index do |row, index|
        label = row.at('label')
        next unless label
        vals = row.search('div.value').map {|x| x.inner_text }

        event = label.inner_text
        time = Time.parse(vals.first[/\d{4}-\d\d-\d\d/])
        time = time + rows.length - index  # to order items within same date
        amount = vals[1][/- Belopp (.+ kr)/, 1]
        balance = vals.last[/- Saldo (.+ kr)/, 1]
        is_debit = !!amount.match(/-\d/)

        items << OpenStruct.new(
          account_name: account_name,
          account_number: account_number,
          event: event,
          time: time,
          amount: amount,
          balance: balance,
          is_debit: is_debit
        )
      end  # each row
    end  # each account

    items.sort_by(&:time)
  end  # def scrape

  def atomize(items)
    updated_at = (items.last ? items.last.time : Time.now).iso8601

    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, version: "1.0"
    xml.feed(xmlns: "http://www.w3.org/2005/Atom") do |feed|

      feed.title     "Kontohistorik för #{@pnr}"
      feed.id        "tag:ica-banken,#{SCHEMA_DATE}:#{@pnr}"
      feed.link      href: 'http://www.icabanken.se'
      feed.updated   updated_at
      feed.author    {|a| a.name 'ICA-banken' }
      feed.generator NAME, version: VERSION
      %w[personal banking finance].each {|cat| feed.category term: cat }

      items.each do |item|
        item_date = [%w[Sön Mån Tis Ons Tors Fre Lör][item.time.wday], item.time.strftime('%Y-%m-%d')].join(' ')
        style = item.is_debit ? 'color:red' : 'color:green'
        feed.entry do |entry|
          # Can't use time-with-index for id, since that will change
          entry.id      "tag:ica-banken,#{SCHEMA_DATE}:#{@pnr}/#{item.account_number};#{item.time.strftime('%Y-%m-%d')};#{item.event.gsub(/\W/, '')};#{item.amount};#{item.balance}".gsub(/\s+/, '')
          entry.title   item.event
          entry.content %{<table>
                            <tr><th>Konto:</th>  <td>#{item.account_name} (#{item.account_number})</td></tr>
                            <tr><th>Datum:</th>  <td>#{item_date}</td></tr>
                            <tr><th>Belopp:</th> <td style="#{style}">#{item.amount}</td></tr>
                            <tr><th>Saldo:</th>  <td>#{item.balance}</td></tr>
                          </table>}, type: 'html'
          entry.updated item.time.iso8601
        end
      end
    end.to_s
  end  # def atomize
end  # class AtomICA


if __FILE__ == $0
  # CLI
  pnr, pwd = ARGV
  AtomICA.new(pnr, pwd).render
end

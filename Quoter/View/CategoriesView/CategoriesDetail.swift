//
//  CategoriesDetail.swift
//  Quoter
//
//  Created by Hung-Chun Tsai on 2021-04-18.
//

import SwiftUI
import CoreData


struct CategoriesDetail: View {
    
    let category: Quote.tag
    @State var quotes = [Quote]()
    @ObservedObject var favorites = Favorites()
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        
        VStack {
            HStack {
                VStack(spacing: 5) {
                    Image("\(category.rawValue)")
                        .resizable()
                        .frame(width: 150, height: 150, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .shadow(color: Color(UIColor.systemGray5), radius: 5, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color.gray.opacity(0.25)))
                        .padding(.top)
                    ZStack{
                        Text(category.rawValue.capitalized)
                            .fontWeight(.regular)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .font(.title2)
                            .foregroundColor(Color(UIColor.systemGray))
                        HStack{
                            Spacer()
                            Button(action: {
                                readJson()
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            })
                            .padding()
                        }
                    }
                    
                    ScrollView() {
                        ForEach(quotes.prefix(10), id: \.id){ quote in
                            VStack(alignment: .leading, spacing: 5){
                                QuoteCardView(quote: quote)
                                    .environment(\.managedObjectContext, self.moc)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.bottom, 10)
                        .animation(.easeInOut)
                    }
                    
                    
                    
                }
                .navigationTitle("\(category.rawValue.capitalized)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
                
                
            }
        }
        .onAppear{
            readJson()
        }
        
    }
    
    func readJson(){
        jsonResponse.getQuotesByCategory(category: self.category) { quotes in
            self.quotes = quotes
            self.quotes.shuffle()
        }
    }
    
}

struct ActionCollectionView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var favorites: Favorites
    
    @State private var presentingSheet = false
    
    var quote: Quote

    var body: some View {
        HStack(alignment: .bottom,spacing: 20) {
            Spacer()
            Button(action: {
                // MARK: - TODO
                if self.favorites.contains(self.quote) {
                    let query = quote.text!
                    let request: NSFetchRequest<FavoriteQuote> = FavoriteQuote.fetchRequest()
                    request.predicate = NSPredicate(format: "text == %@", query)
                    
                    let objects = try! moc.fetch(request)
                    for obj in objects {
                        moc.delete(obj)
                    }
                    
                    do {
                        try moc.save()
                    } catch {
                        // Do something... fatalerror
                    }
                    self.favorites.remove(self.quote)
                } else {
                    
                    let newFavorite = FavoriteQuote(context: self.moc)
                    newFavorite.text = quote.text
                    newFavorite.author = quote.author
                    newFavorite.tag = quote.tag
                    try? self.moc.save()
                    
                    print("add")
                    self.favorites.add(self.quote)
                    print(quote)
                }
            }) {
                if self.favorites.contains(self.quote) {
                    Image(systemName: "heart.fill")
                } else {
                    Image(systemName: "heart")
                }
            }
            .foregroundColor(.red)
            Button(action: {
                presentingSheet.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            .sheet(isPresented: $presentingSheet) {
                ShareQuoteView(quoteText: quote.text!, quoteAuthor: quote.author!)
            }
            
            
        }// HStack
        
    }
}


struct QuoteCardView: View {
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var favorites: Favorites
    
    var quote: Quote
    
    
    var body: some View {
        GroupBox(
            label:
                HStack {
                    Spacer()
                    Text("-\(quote.author ?? "Unkown Author")-" )
                    Spacer()
                }
        ) {
            Divider().padding(.vertical, 5)
            
            VStack(spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text(quote.text ?? "None")
                        .font(.callout)
                }
                
                ActionCollectionView(quote: quote)
                
                
            }
            .font(.title2)
        }//-: GroupBox
        .environmentObject(favorites)

        
        
        
    }
}



struct CategoriesDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CategoriesDetail(category: Quote.tag.attitude)
                .environmentObject(Favorites())
            
            
            QuoteCardView(quote: testQuote)
                .environmentObject(Favorites())
                .previewLayout(.sizeThatFits)
                .padding()
            
            QuoteCardView(quote: testQuote)
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
                .environmentObject(Favorites())
                .previewLayout(.sizeThatFits)
                
                .padding()
        }
    }
}
